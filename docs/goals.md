# Goals

## Questions to answer

* Are any particularly easier or harder to modify a file that is published?
* Are any obviously going to have trouble with the workload?
* What are the differences in XQuery full-text indexing and searching?
* How easy (or hard) is it to handle hits? (I.e., report a summary of them to user, highlight them, move from one to the next.)
* Can we easily generate URLs that point *into* files, not just at them? (If we can't point at them, I think it's a non-starter.) Both so that one can point to a section of text, but also so that a user can retrieve only a section of text. (AC says both of these are pretty easy to do.)
* Chunking.
* How hard is debugging?
* Differences in security? E.g., would it be easy to have the XML database keep track of users & IP ranges instead of our current system?
* Which version of XSLT do we get to use? Of XQuery?
* Will database allow you to run XSLT or XQuery that is stored elsewhere? (Or do cross-site scripting rules apply?) This may not be important for WWO, but would be nice to know, anyway.
* How well does database survive (and get re-launched) when system crashes?
* How easy is it to back up and recover stored information?
* How easy is it to use a version control system for code database uses?
* How easy is it to store a cookie with data about a user's session (so we could, e.g., save complex searches or search results)?
* How hard is it to upgrade the underlying database to a new version, but keep our code?
