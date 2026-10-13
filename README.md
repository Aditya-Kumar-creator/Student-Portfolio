# Student Portfolio

A web app where students record their workshops, competitions, hackathons, volunteering and club activity in one place, get it verified by faculty, and produce a summary, a report and a resume from it.

It is plain HTML, CSS and JavaScript with no build step. Supabase provides the login, the database, the file storage and the access rules, so there is no custom server.

**Live site:** https://YOUR-USERNAME.github.io/REPO-NAME/ (replace with your own address once it is published)

## Features

- Registration and login with two roles: student and faculty
- Add, edit and delete activities (title, category, status, date, hours, organizer, role, outcome, proof link, skills, notes)
- Categories: Workshop, Competition, Hackathon, Volunteering, Club
- Up to 5 optional links per activity (website you built, event website, code repository, other)
- Search, filters and sorting, with status tracking (Planned, In Progress, Completed)
- Dashboard with totals, a monthly hours chart, category split, top skills, a credit goal and an automatic summary
- Faculty verification: only Completed and Verified hours count as credits
- Certificate upload (PDF, PNG or JPG up to 400 KB) with a Certificates tab to open and print them
- Eight rule-based badges and milestones
- Resume builder with print and copy
- Printable report
- Events with registration, which adds the event to a student's portfolio as Planned
- Faculty class overview and review queue
- Responsive layout, Privacy Policy and Terms pages

## Project structure

```
student-portfolio/
  index.html              Portal: login, dashboard, events, class overview, plugin frame
  portfolio.html          Portfolio plugin: activities, certificates, resume, review queue
  privacy.html            Privacy Policy (draft, fill in the placeholders)
  terms.html              Terms and Conditions (draft, fill in the placeholders)
  supabase-config.js      Your Supabase project URL and publishable key
  database/
    supabase-setup.sql    Tables, access rules, functions and the certificates bucket
    remove-qr-checkin.sql Run once only if your project was set up before QR check-in was removed
  LICENSE
  README.md
```

## Set up

1. Create a free project at https://supabase.com.
2. In the Supabase dashboard open **SQL Editor**, paste all of `database/supabase-setup.sql` and run it. It is safe to run again.
3. Under **Authentication, Sign In / Providers, Email**, make sure Email is on. Turn **Confirm email** off while testing and back on before going live.
4. In **Project Settings, API Keys**, copy the Project URL and the publishable key (it starts with `sb_publishable_`).
5. Put them in `supabase-config.js`:

   ```js
   window.SUPABASE_URL = "https://YOUR-PROJECT.supabase.co";
   window.SUPABASE_KEY = "your publishable key";
   ```

Do not put the secret key or the `service_role` key in this project. The publishable key is designed to be public, and the access rules in the database protect the data.

## Run locally

The pages must be opened through a web server, not by double-clicking the files.

```
cd student-portfolio
python -m http.server 8000
```

Then open http://localhost:8000/ in your browser.

## Create a faculty account

There is no faculty sign-up form on purpose.

1. Register a normal account in the app with an ID such as `FAC001`.
2. In the Supabase SQL Editor run:

   ```sql
   update profiles set role = 'faculty' where student_id = 'FAC001';
   ```

3. Log out and log in again.

## Deploy on GitHub Pages

The site is static files only, so GitHub Pages can host it for free. No other website is needed.

1. Create a GitHub repository and upload the files in this folder (not the zip itself). Use your own `supabase-config.js` with your key.
2. In the repository open **Settings, Pages**. Under **Build and deployment**, set **Source** to **Deploy from a branch**. Choose the `main` branch and the `/ (root)` folder, then click **Save**.
3. Wait a few minutes. The address of your site is shown at the top of the Pages settings, in the form `https://YOUR-USERNAME.github.io/REPO-NAME/`.
4. In Supabase open **Authentication, URL Configuration** and set the Site URL to that address. Turn **Confirm email** back on before real users sign up.
5. Open the live address and test registration, login, saving an activity and a certificate upload.

To update the site later, edit or upload a file in the repository. GitHub Pages publishes the change automatically after each commit.

**Alternative:** Netlify also works. Import the repository, leave the build command empty, and publish from the root folder.

## How it works

- `index.html` handles login through Supabase Auth, builds the sidebar from a list of modules, and loads `portfolio.html` in a frame as a plugin. Adding another plugin means adding one entry to the `MODULES` list.
- `portfolio.html` reads the same login session and talks to Supabase directly for activities, files and the review queue.
- Row level security in the database lets students see only their own data, stops them from setting Verified, and gives faculty access to review and the class overview.

## Known limitations

- Faculty accounts are made by editing the database, and there is no admin screen.
- There is no forgot-password screen, no notifications and no shareable resume link.
- The credit goal is stored in the browser, so it does not follow a student to another device.

## License

MIT. See the LICENSE file and replace `Aditya Kumar` with yours.
