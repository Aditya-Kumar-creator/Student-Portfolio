# Student Portfolio

A web app where students record their workshops, competitions, hackathons, volunteering and club activity in one place, get it verified by faculty, and produce a summary, a report and a resume from it.

It is plain HTML, CSS and JavaScript with no build step. Supabase provides the login, the database, the file storage and the access rules, so there is no custom server.

**Live site:** https://aditya-kumar-creator.github.io/Student-Portfolio/

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
  LICENSE
  README.md
```

## How it works

- `index.html` handles login through Supabase Auth, builds the sidebar from a list of modules, and loads `portfolio.html` in a frame as a plugin. Adding another plugin means adding one entry to the `MODULES` list.
- `portfolio.html` reads the same login session and talks to Supabase directly for activities, files and the review queue.
- Row level security in the database lets students see only their own data, stops them from setting Verified, and gives faculty access to review and the class overview.

## Known limitations

- Faculty accounts are made by editing the database, and there is no admin screen.
- There is no forgot-password screen, no notifications and no shareable resume link.
- The credit goal is stored in the browser, so it does not follow a student to another device.

## License

MIT. See the LICENSE file .
