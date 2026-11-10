# SNDK Online Ordering — Render Static Site

Repository-ready package based on SNDK Online Ordering v0.7.2.

## Deploy to Render
1. Create a new **public or private GitHub repository** and upload the contents of this folder to its root.
2. In Render, choose **New → Blueprint** and connect that GitHub repository, or create a **Static Site** from the repository.
3. If creating a Static Site manually:
   - Build Command: leave empty
   - Publish Directory: `.`
4. Deploy. Render will provide an HTTPS `onrender.com` address.

## Notes
- This is a static HTML prototype. It uses browser localStorage; orders and admin changes are not yet shared across devices and are not synced with SNDK POS.
- The interactive map requires an internet connection and external map resources to load. Browser location access requires HTTPS and user permission.
- Do not put passwords, API keys, or private customer data in this repository.
