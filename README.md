# Impact-Siswa

Impact-Siswa is a JSP/Servlet + MySQL volunteer hours and social credit system for CSC584.

The prototype has been converted into a working web application with:

- Student, club leader, and admin login sessions
- Registration with hashed passwords
- Event marketplace with join-request approval
- Student hour claim submission with proof image upload
- Club leader/admin approval workflow
- Event CRUD
- Admin faculty, club, and university unit management
- Admin user role management
- Chart.js reports
- MySQL schema and seed data

## Quick Start

1. Start MySQL in Laragon.
2. Import the database:

```bat
mysql -uroot < database\impact_siswa.sql
```

If your MySQL root password is `root`:

```bat
mysql -uroot -proot < database\impact_siswa.sql
```

3. Run the app:

```bat
run.bat
```

4. Open:

```text
http://localhost:8080/impact-siswa
```

Uploaded proof images are stored in `uploads\hour-proofs` by default. Set `IMPACT_UPLOAD_DIR` before running the app if you want to store uploads somewhere else.

## Demo Accounts

| Role | Login | Password |
| --- | --- | --- |
| Student | `student@impact.edu.my` | `student123` |
| Club Leader | `leader@impact.edu.my` | `leader123` |
| Admin | `admin@impact.edu.my` | `admin123` |

Full documentation is in [DOCUMENTATION.md](DOCUMENTATION.md).
