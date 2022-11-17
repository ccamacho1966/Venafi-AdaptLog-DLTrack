# Download Tracker

Preserve the user identity and time that a certificate was last downloaded as a pair of custom fields.

## Rationale

All too often the processes and costs associated with maintaining a large certificate inventory are ignored by your customers/users. I have seen far too often a request to automatically renew certificates that are not in use. While it may be easy to use application records to confirm that some certificates are at least installed, if not in use, many certificates may require manual processing by the customer/user. Are they even really downloading the certificate or is it really a dead database entry costing you licensing money for Venafi and your CA? How would you even check this at renewal time? Log retention consumes a large amount of database space, slowing the system and wasting resources. You could send these log entries to another system, but then you would be forced to research this data outside of Venafi.

With the addition of 2 custom fields and this extremely simple adaptable log script, you can easily track the most recent download of each certificate.

## Installation

Upload the adaptable log driver file 'Download Tracker.ps1' to all Venafi servers.  
The default folder location would be 'C:\Program Files\Venafi\Scripts\AdaptableLog\'.

You will need to create 2 new custom fields. The names are suggestions only and can be altered.  
Currently, this is found under the 'Configuration' menu. The option name is 'Custom Fields'.

- Suggested Name:   Last Downloaded By
  - Field Type: String
  - Apply To:   Certificates
  - Make Field: Read Only
- Suggested Name:   Last Downloaded At
  - Field Type: Date/Time (check both boxes for date and time)
  - Apply To:   Certificates
  - Make Field: Read Only

Record the GUID values for both of these custom fields.

Proceed to the logging configuration. Currently, this is done by clicking on 'Logs' in the menu.

- Right click on 'Channel'
- Hover over 'Add' and select 'Adaptable'
  - Adaptable Logging Channel Name: Download Tracker
  - PowerShell Script: Download Tracker
  - Username Field GUID: *{value-recorded-earlier}*
  - Date/Time Field GUID: *{value-recorded-earlier}*
  - Click on **[SAVE]**
- Right click on 'Notification Rules'
- Hover over 'Add' and select 'Notification'
  - Notification Rule Name: Certificate Downloaded
  - 'Disabled' should **not** be checked
  - Rules: IF [Event ID] [matches] [Aperture - Certificate Downloaded]
  - Target Channel: \VED\Logging\Channels\Download Tracker
  - Click on **[SAVE]**

Download Tracker is now installed and enabled.

## Usage

These fields can be viewed in the 'Renewal Details', but I find it more useful to have them added as columns in my admin inventory view. This, in addition to 'Installations', makes it quick and easy for me to see if there are known/managed installations on record and/or if the certificate has even been downloaded. If there are no known installations and the certificate has never been downloaded then I have good reason to question the need for a renewal.

## Important Note

This is a **forward-looking** enhancement! This doesn't scour your Venafi logs and load historical data. This only tracks downloads from the point you installed the log driver. In practical terms, this means you will need to have created/renewed a certificate one time while this driver is installed and then be coming back to the certificate for a new renewal request decision - i.e. it will probably be a year after you first install this driver that you begin to get value from the data it preserves.

## Support
This is the very definition of a minimalistic driver. It requires no additional connectivity or API access. It would be pretty hard to break this, but log an issue and I'll have a look.

## Roadmap
While I could 'simplify' the driver setup by not using GUID strings, this would complicate the driver code and adds a lot of potential to break things. I've had enough random Venafi API issues over the years to know that the one-time hassle of getting/inputting GUID strings is worth the effort as it makes this driver pretty bullet-proof. I've done exactly that in other drivers that need to leverage the API for a variety of reasons, but for this driver I've chosen stability over setup simplicity.

## Contributing
I'm open to suggestions, but again I don't want to sacrifice stability. As this driver is written, there are no changes necessary to your Venafi OS/application environment and I like it that way.
