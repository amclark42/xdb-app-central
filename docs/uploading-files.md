# Uploading files

## BaseX



## eXist-DB

### Browser

* Log into eXist via the web Dashboard.
* Open the Collections app.
* Navigate the file structure until you get to the collection where the new files will go.
* Once there, click the last button (a cylinder with a plus sign) to upload files from your local machine.

### Java Console

This method depends upon the files being available in the server. Either SCP them in from your local machine, or use version control to pull in updates.

* SSH into the server with the `-X` or `-Y` flag.
* Navigate into eXist's home directory.
* Open the Java Client: `java -jar start.jar client`.
* Log in to the database.
* Navigate the file structure until you get to the collection where the new files will go.
* Once there, use the File menu, the storage button (a document with a plus sign), or `CTRL-s` to upload files from the server into the database.

## MarkLogic

### Browser


### Command Line


