# Impact-Siswa System Documentation

## 1. Overview

Impact-Siswa is a JSP/Servlet web system for managing university volunteer events, student hour claims, approval workflows, social credit badges, and management reports. It converts the original static prototype into a database-backed application following the CSC584 proposal.

## 2. Technology Stack

- Java 21
- Jakarta Servlet and JSP
- JSTL
- MySQL 8
- Maven Wrapper
- Jetty Maven Plugin for local running
- Chart.js for dashboard/report charts
- Bootstrap Icons plus custom CSS

## 3. Main Modules

- Authentication: login, student registration, logout, and session protection.
- Student dashboard: total hours, badges, charts, and upcoming events.
- Event marketplace: students browse events and request to join.
- My Hours: students submit hour claims for approved event registrations that do not already have a pending or approved claim, attach proof images, view claim details, and cancel pending claims.
- Pending Approvals: club leaders/admins approve or reject event join requests and hour claims with remarks.
- Manage Events: club leaders/admins create, read, update, and delete event records.
- Reports: faculty hours, top organizers, monthly trends, total impact, and recent logs.
- Faculties & Clubs: admins manage the active faculties, clubs, and university units used by forms and reports.
- Admin Users: admins review accounts, assign roles, and connect users to a faculty, club, or unit.
- Profile: users update display profile details.

## 4. Database Setup

1. Start MySQL from Laragon.
2. Open a terminal in this project folder.
3. Import the schema:

```bat
mysql -uroot < database\impact_siswa.sql
```

If your Laragon MySQL root password is `root`, use:

```bat
mysql -uroot -proot < database\impact_siswa.sql
```

The application defaults to:

- JDBC URL: `jdbc:mysql://localhost:3306/impact_siswa?useSSL=false&serverTimezone=Asia/Kuala_Lumpur`
- User: `root`
- Password: blank by default in Laragon

You can override these without editing code:

```bat
set IMPACT_DB_URL=jdbc:mysql://localhost:3306/impact_siswa?useSSL=false&serverTimezone=Asia/Kuala_Lumpur
set IMPACT_DB_USER=root
set IMPACT_DB_PASSWORD=yourpassword
```

Hour claim proof images are stored in:

```text
uploads\hour-proofs
```

Set `IMPACT_UPLOAD_DIR` before running the app to store uploads in another folder. Only the generated image filename is stored in MySQL.

## 5. Demo Accounts

| Role | Login | Password |
| --- | --- | --- |
| Student | `student@impact.edu.my` | `student123` |
| Club Leader | `leader@impact.edu.my` | `leader123` |
| Admin | `admin@impact.edu.my` | `admin123` |

Passwords are stored as PBKDF2 hashes in the `users.password_hash` column.

## 6. Running the System

```bat
run.bat
```

Or:

```bat
mvnw.cmd jetty:run
```

Open:

```text
http://localhost:8080/impact-siswa
```

## 7. Database Design

Core proposal tables:

- `users`: stores students, club leaders, and admins. Includes `total_hours` for badge calculation.
- `affiliations`: stores admin-managed faculties, clubs, and university units for dropdowns and reporting labels.
- `categories`: stores volunteer/event categories such as Education and Environment.
- `events`: stores volunteer opportunities created by club leaders/admins.
- `hour_logs`: stores submitted volunteer hour claims, proof image filenames, and approval audit details.

Added practical table:

- `event_registrations`: stores student join requests with pending, approved, rejected, and cancelled statuses. Approved registrations unlock hour claim submission.

Important relationships:

- `events.cat_id -> categories.cat_id`
- `events.created_by -> users.user_id`
- `event_registrations.event_id -> events.event_id`
- `event_registrations.user_id -> users.user_id`
- `hour_logs.user_id -> users.user_id`
- `hour_logs.event_id -> events.event_id`
- `hour_logs.approved_by -> users.user_id`

## 8. Role Access

| Feature | Student | Club Leader | Admin |
| --- | --- | --- | --- |
| Dashboard | Yes | Yes | Yes |
| Browse events | Yes | Yes | Yes |
| Request to join events | Yes | No | No |
| Approve/reject join requests | No | Yes | Yes |
| Submit hour claims | Yes | No | No |
| Approve/reject claims | No | Yes | Yes |
| Manage events | No | Yes | Yes |
| Reports | No | Yes | Yes |
| Manage faculties/clubs | No | No | Yes |
| Manage users | No | No | Yes |
| Profile update | Yes | Yes | Yes |

Protected routes are enforced by `AuthFilter`.

## 9. CRUD Mapping

- Create users: registration page creates student accounts.
- Read users: admin user panel.
- Update users: profile update and admin role assignment.
- Create affiliations: Faculties & Clubs page.
- Read affiliations: registration, profile, users, and Faculties & Clubs pages.
- Update affiliations: edit action on Faculties & Clubs page.
- Delete affiliations: delete action on Faculties & Clubs page.
- Create events: Manage Events page.
- Read events: Events and Manage Events pages.
- Update events: Edit action on Manage Events page.
- Delete events: Delete action on Manage Events page.
- Create event registrations: student Join button creates a pending request.
- Update event registrations: Approvals page approves/rejects requests; students can cancel their own request/registration.
- Create hour logs: My Hours page after the event registration is approved. Events with pending or approved claims are removed from the submission dropdown; rejected claims can be corrected and submitted again.
- Read hour logs: My Hours, Approvals, Reports.
- Update hour logs: approval/rejection workflow.
- Delete hour logs: students can cancel pending claims.

## 10. Report Generation

Reports are generated from live MySQL queries in `ReportDAO` and visualized with Chart.js:

- Hours by faculty.
- Top 5 organizers.
- Monthly approved hours trend.
- Total university impact.
- Pending approvals summary.
- Recent hour logs table.

## 11. Important Source Files

- `database/impact_siswa.sql`: database schema and seed data.
- `src/main/java/com/impactsiswa/db/DBConnection.java`: database connection settings.
- `src/main/java/com/impactsiswa/util/PasswordUtil.java`: password hashing and verification.
- `src/main/java/com/impactsiswa/util/UploadStorage.java`: proof image storage folder resolution.
- `src/main/java/com/impactsiswa/filter/AuthFilter.java`: session and role access control.
- `src/main/java/com/impactsiswa/dao`: database queries.
- `src/main/java/com/impactsiswa/servlet`: page controllers and form actions.
- `src/main/webapp/WEB-INF/views`: JSP pages.
- `src/main/webapp/css/app.css`: application styling.

## 12. Notes for Presentation

- The system uses prepared statements for database input.
- Sessions protect all `/app/*` pages.
- Uploaded proof images are served through an authenticated `/app/proofs/*` route.
- Approval uses a database transaction so hour status and `users.total_hours` stay synchronized.
- Badges are calculated dynamically from total hours:
  - Bronze: below 35 hours
  - Silver: 35 to 69.99 hours
  - Gold: 70 to 99.99 hours
  - Platinum: 100+ hours
- Flash messages show success/error feedback after create, update, delete, and approval actions.
