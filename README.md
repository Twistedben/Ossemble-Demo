Source Code Demo

##A lot of this code was written when I was still learning Ruby on Rails, learning as I built the app; hence, much of this code is smelly and not optimally written.

Some source code extracted from Ossemble.com to illustrate the codebase involved in it while allowing the main codebase to stay private since it's an active SaaS product. 

Much of the code is currently not in active use but legacy code from before a pivot from a free social media civic platform to a Regional Organization and Government B2G productivity and collaboration subscription app.

Cloning the app will not work, as I stipped out sensitive files intentionally. (deleted config files, production and deployment files, DB folder, and images). Take note, some of this code is extremely old and was written when I was a beginner at Ruby and RoR, and may have never been refactored. So there may be some really smelly code scattered throughout.


**Some features:**

    a. S3 hosting for uploaded files and images using Active Storage and mini-magick.

    b. Upvoting system, commenting system with threading, AJAX rendered for instant comment replies and posting.

    c. Notifications sent aynchronously when activity is relevant to user.

    d. User accounts, profile information, private channels and workplaces for users to join. Email inviting system via instant join links and on-site forms with tokenization.

    e. Archiving posts and creating private cloud uploads with file sharing.

    f. User based admin system with distinct privileges and user management.

    g. Leaflet and OSM for posting and drawing on regional-based maps. Custom configuration for geoJSON, using Census API to draw polygonal shapes for boundaries of Congressional Districts, Counties, and Cities. As well as drawing your own regional boundary.

    h. A private or public workplace/channel with an aassigned map, sectioned feed of posts, filtered by category and type, and displayed by trending.

    i. Many other features currently deprecated due to change in vision, like searching, following, sharing via Social Media, etc..


## Software

---

- Ruby 2.5.3p105 (2018-10-18 revision 65156) [x86_64-linux]

- Rails: 5.2.0

- Server: Puma with Ruby 2.5.3 running on 64bit Amazon Linux/2.9.1 (AWS Elastic Beanstalk Production Environment)

- Database: PostgreSQL 10.6 (Pro / Dev)

- Ruby Version Manager: 1.29.4

- Webpacker / Yarn / NPM

- Docker for local development

- Languages/Frameworks/Libraries: Ruby, Rails, HTML5 (BootStrap 4, Tachyions, Font Awesome), CSS3 (SASS), JavaScript (CoffeeScript, jQuery, Leaflet), Testing (CapyBara, RSpec, Factory Bot)

---

### Authentication

    Devise
    Pundit (app/policies/...)
    Manually written code for authorization 

---

#### Screenshots

![alt text](https://github.com/Twistedben/Ossemble-Demo/blob/master/app/assets/screenshots/Ossemble_Feed.png "Main Channel Feed")
![alt text](https://github.com/Twistedben/Ossemble-Demo/blob/master/app/assets/screenshots/Ossemble_New_Post.png "Forum Post Show Page")
![alt text](https://github.com/Twistedben/Ossemble-Demo/blob/master/app/assets/screenshots/Ossemble_New_Map.png "New Map Post Page")
![alt text](https://github.com/Twistedben/Ossemble-Demo/blob/master/app/assets/screenshots/Ossemble_Assigning_Map.png "Assigning a Map to Channel")
