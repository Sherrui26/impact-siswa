const demoUsers = {
  student: {
    name: "Nur Fadhlin Qistina",
    matric: "2023349961",
    email: "student@impact.edu.my",
    phone: "013-555 4012",
    faculty: "Computer and Mathematical Sciences",
    role: "student",
    totalHours: 42.5,
  },
  club_leader: {
    name: "Muhammad Sharul Aiman",
    matric: "CLB-2026-02",
    email: "leader@impact.edu.my",
    phone: "019-555 7710",
    faculty: "Student Affairs Club",
    role: "club_leader",
    totalHours: 86,
  },
  admin: {
    name: "BHEPA Administrator",
    matric: "ADMIN-001",
    email: "admin@impact.edu.my",
    phone: "03-5544 2200",
    faculty: "University Administration",
    role: "admin",
    totalHours: 0,
  },
};

const state = {
  authMode: "login",
  currentUser: null,
  activeView: "dashboard",
  editingEventId: null,
  joinedEventIds: new Set([2]),
  events: [
    {
      id: 1,
      name: "River Cleanup at Sungai Klang",
      category: "Environment",
      date: "2026-06-06",
      location: "Sungai Klang",
      hours: 6,
      slotsLeft: 18,
      organizer: "Eco Warriors Club",
      owner: "Eco Warriors Club",
    },
    {
      id: 2,
      name: "STEM Mentoring for Primary Students",
      category: "Education",
      date: "2026-06-12",
      location: "SK Seksyen 7",
      hours: 4,
      slotsLeft: 9,
      organizer: "Computer Science Society",
      owner: "Computer Science Society",
    },
    {
      id: 3,
      name: "Food Bank Packing Drive",
      category: "Community",
      date: "2026-06-19",
      location: "Dewan Mawar",
      hours: 5,
      slotsLeft: 24,
      organizer: "BHEPA",
      owner: "BHEPA",
    },
    {
      id: 4,
      name: "Campus Health Awareness Booth",
      category: "Health",
      date: "2026-07-02",
      location: "Faculty Walkway",
      hours: 3,
      slotsLeft: 15,
      organizer: "Medical Volunteer Team",
      owner: "Medical Volunteer Team",
    },
    {
      id: 5,
      name: "Recycling Collection Weekend",
      category: "Environment",
      date: "2026-07-11",
      location: "College Zone A",
      hours: 4,
      slotsLeft: 31,
      organizer: "Green Campus Unit",
      owner: "Green Campus Unit",
    },
  ],
  hourLogs: [
    {
      id: 1001,
      student: "Nur Fadhlin Qistina",
      matric: "2023349961",
      faculty: "Computer and Mathematical Sciences",
      eventId: 2,
      hours: 4,
      submitted: "2026-05-14",
      status: "approved",
      approvedBy: "Muhammad Sharul Aiman",
      approvedAt: "2026-05-15",
      remarks: "Attendance verified by facilitator.",
    },
    {
      id: 1002,
      student: "Nur Fadhlin Qistina",
      matric: "2023349961",
      faculty: "Computer and Mathematical Sciences",
      eventId: 1,
      hours: 6,
      submitted: "2026-05-16",
      status: "pending",
      approvedBy: "",
      approvedAt: "",
      remarks: "Uploaded group photo and supervisor signature.",
    },
    {
      id: 1003,
      student: "Aina Sofea",
      matric: "2023551201",
      faculty: "Business and Management",
      eventId: 3,
      hours: 5,
      submitted: "2026-05-15",
      status: "pending",
      approvedBy: "",
      approvedAt: "",
      remarks: "Waiting for club leader confirmation.",
    },
    {
      id: 1004,
      student: "Daniel Lee",
      matric: "2023119088",
      faculty: "Engineering",
      eventId: 5,
      hours: 7,
      submitted: "2026-05-13",
      status: "rejected",
      approvedBy: "BHEPA Administrator",
      approvedAt: "2026-05-14",
      remarks: "Submitted event date does not match attendance sheet.",
    },
    {
      id: 1005,
      student: "Siti Hajar",
      matric: "2023900142",
      faculty: "Education",
      eventId: 4,
      hours: 3,
      submitted: "2026-05-12",
      status: "approved",
      approvedBy: "BHEPA Administrator",
      approvedAt: "2026-05-13",
      remarks: "Approved with booth duty checklist.",
    },
  ],
};

const facultyHours = [
  ["Computer and Mathematical Sciences", 420],
  ["Engineering", 365],
  ["Business", 290],
  ["Education", 238],
  ["Health Sciences", 176],
];

const clubHours = [
  ["Eco Warriors Club", 188],
  ["BHEPA", 164],
  ["Computer Science Society", 146],
  ["Medical Volunteer Team", 119],
  ["Green Campus Unit", 92],
];

const monthlyHours = [
  ["Jan", 120],
  ["Feb", 180],
  ["Mar", 240],
  ["Apr", 310],
  ["May", 390],
  ["Jun", 460],
];

const navByRole = {
  student: [
    ["dashboard", "Dashboard", "DB"],
    ["events", "Events", "EV"],
    ["hours", "My Hours", "HR"],
  ],
  club_leader: [
    ["dashboard", "Dashboard", "DB"],
    ["events", "Events", "EV"],
    ["approvals", "Pending Approvals", "AP"],
    ["manage", "Manage Events", "MG"],
    ["reports", "Reports", "RP"],
  ],
  admin: [
    ["dashboard", "Dashboard", "DB"],
    ["events", "Events", "EV"],
    ["approvals", "Pending Approvals", "AP"],
    ["manage", "Manage Events", "MG"],
    ["reports", "Reports", "RP"],
  ],
};

const app = document.querySelector("#app");
const toast = document.querySelector("#toast");

function roleLabel(role) {
  return {
    student: "Student",
    club_leader: "Club Leader",
    admin: "Admin",
  }[role];
}

function today() {
  return "2026-05-17";
}

function formatDate(date) {
  return new Intl.DateTimeFormat("en-MY", {
    day: "2-digit",
    month: "short",
    year: "numeric",
  }).format(new Date(`${date}T00:00:00`));
}

function formatNumber(value) {
  return new Intl.NumberFormat("en-MY").format(value);
}

function getInitials(name) {
  return name
    .split(" ")
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part[0])
    .join("")
    .toUpperCase();
}

function badgeForHours(hours) {
  if (hours >= 100) return ["Platinum", "purple"];
  if (hours >= 70) return ["Gold", "amber"];
  if (hours >= 35) return ["Silver", "green"];
  return ["Bronze", ""];
}

function eventById(id) {
  return state.events.find((event) => event.id === Number(id));
}

function pendingLogs() {
  return state.hourLogs.filter((log) => log.status === "pending");
}

function currentUserLogs() {
  if (!state.currentUser) return [];
  return state.hourLogs.filter((log) => log.matric === state.currentUser.matric);
}

function showToast(message) {
  toast.textContent = message;
  toast.classList.add("show");
  window.clearTimeout(showToast.timer);
  showToast.timer = window.setTimeout(() => toast.classList.remove("show"), 2600);
}

function render() {
  app.innerHTML = state.currentUser ? renderShell() : renderAuth();
}

function renderAuth() {
  const isRegister = state.authMode === "register";
  return `
    <main class="auth-page">
      <section class="auth-hero">
        <div class="brand-row">
          <div class="row-center">
            <div class="brand-mark">IS</div>
            <div class="brand-copy">
              <strong>Impact-Siswa</strong>
              <span>Volunteer Hours & Social Credit System</span>
            </div>
          </div>
        </div>
        <div>
          <h1>Track campus volunteering from signup to verified impact.</h1>
          <p>A platform for students, club leaders, and administrators to manage opportunities, approvals, social credit badges, and reporting in one place.</p>
        </div>
        <div class="hero-metrics">
          <div class="hero-metric"><strong>1,489</strong><span>approved university hours</span></div>
          <div class="hero-metric"><strong>32</strong><span>active volunteer events</span></div>
          <div class="hero-metric"><strong>18</strong><span>pending approvals</span></div>
        </div>
      </section>

      <section class="auth-panel-wrap">
        <div class="auth-card">
          <h2>${isRegister ? "Create account" : "Sign in"}</h2>
          <p>${isRegister ? "Register as a student or club leader for the demo." : "Use any email and password, or jump into a demo role."}</p>

          <div class="auth-tabs" role="tablist" aria-label="Authentication">
            <button class="auth-tab ${!isRegister ? "active" : ""}" data-auth-mode="login">Login</button>
            <button class="auth-tab ${isRegister ? "active" : ""}" data-auth-mode="register">Register</button>
          </div>

          ${isRegister ? renderRegisterForm() : renderLoginForm()}
        </div>
      </section>
    </main>
  `;
}

function renderLoginForm() {
  return `
    <form class="form-grid" data-form="login">
      <div class="field">
        <label for="login-id">Email or Matric Number</label>
        <input id="login-id" name="loginId" placeholder="student@impact.edu.my" autocomplete="username" required />
      </div>
      <div class="field">
        <label for="login-password">Password</label>
        <input id="login-password" name="password" type="password" placeholder="Any password works" autocomplete="current-password" required />
      </div>
      <button class="primary-btn" type="submit">Login</button>
    </form>
    <div class="quick-login">
      <button class="secondary-btn" data-login-role="student">Student Demo</button>
      <button class="secondary-btn" data-login-role="club_leader">Leader Demo</button>
      <button class="secondary-btn" data-login-role="admin">Admin Demo</button>
    </div>
  `;
}

function renderRegisterForm() {
  return `
    <form class="form-grid" data-form="register">
      <div class="form-grid two-col">
        <div class="field">
          <label for="reg-name">Full Name</label>
          <input id="reg-name" name="name" placeholder="Your full name" required />
        </div>
        <div class="field">
          <label for="reg-matric">Matric Number</label>
          <input id="reg-matric" name="matric" placeholder="2026xxxxxx" required />
        </div>
      </div>
      <div class="form-grid two-col">
        <div class="field">
          <label for="reg-email">Email</label>
          <input id="reg-email" name="email" type="email" placeholder="name@student.uitm.edu.my" required />
        </div>
        <div class="field">
          <label for="reg-phone">Phone</label>
          <input id="reg-phone" name="phone" placeholder="012-345 6789" required />
        </div>
      </div>
      <div class="form-grid two-col">
        <div class="field">
          <label for="reg-faculty">Faculty</label>
          <select id="reg-faculty" name="faculty" required>
            <option>Computer and Mathematical Sciences</option>
            <option>Engineering</option>
            <option>Business and Management</option>
            <option>Education</option>
            <option>Health Sciences</option>
          </select>
        </div>
        <div class="field">
          <label for="reg-role">Role</label>
          <select id="reg-role" name="role" required>
            <option value="student">Student</option>
            <option value="club_leader">Club Leader</option>
          </select>
        </div>
      </div>
      <div class="field">
        <label for="reg-password">Password</label>
        <input id="reg-password" name="password" type="password" placeholder="Minimum 8 characters" required minlength="8" />
      </div>
      <button class="primary-btn" type="submit">Create Account</button>
    </form>
  `;
}

function renderShell() {
  return `
    <div class="app-shell">
      ${renderSidebar()}
      <main class="main">
        ${renderTopbar()}
        <section class="content">
          ${renderActiveView()}
        </section>
      </main>
    </div>
  `;
}

function renderSidebar() {
  const links = navByRole[state.currentUser.role];
  const [badgeName, badgeClass] = badgeForHours(state.currentUser.totalHours);
  return `
    <aside class="sidebar">
      <div class="sidebar-brand">
        <div class="app-mark">IS</div>
        <div>
          <strong>Impact-Siswa</strong>
          <span>${roleLabel(state.currentUser.role)} workspace</span>
        </div>
      </div>
      <nav class="nav" aria-label="Main navigation">
        ${links
          .map(
            ([id, label, icon]) => `
              <button class="nav-link ${state.activeView === id ? "active" : ""}" data-view="${id}">
                <span class="nav-icon">${icon}</span>
                ${label}
              </button>
            `,
          )
          .join("")}
      </nav>
      <div class="sidebar-card">
        <strong>${badgeName} Badge</strong>
        <p>${state.currentUser.totalHours} verified hours recorded for this demo profile.</p>
        <span class="pill ${badgeClass}">${roleLabel(state.currentUser.role)}</span>
      </div>
    </aside>
  `;
}

function renderTopbar() {
  return `
    <header class="topbar">
      <div class="profile-mini">
        <div class="avatar">${getInitials(state.currentUser.name)}</div>
        <div>
          <strong>${state.currentUser.name}</strong>
          <span>${state.currentUser.faculty}</span>
        </div>
      </div>
      <div class="topbar-actions">
        <select class="role-select" data-role-switch aria-label="Switch demo role">
          ${Object.keys(demoUsers)
            .map(
              (role) => `
                <option value="${role}" ${state.currentUser.role === role ? "selected" : ""}>${roleLabel(role)}</option>
              `,
            )
            .join("")}
        </select>
        <button class="secondary-btn" data-action="logout">Sign Out</button>
      </div>
    </header>
  `;
}

function renderActiveView() {
  return {
    dashboard: renderDashboard,
    events: renderEvents,
    hours: renderHours,
    approvals: renderApprovals,
    manage: renderManageEvents,
    reports: renderReports,
  }[state.activeView]();
}

function renderDashboard() {
  const role = state.currentUser.role;
  const [badgeName, badgeClass] = badgeForHours(state.currentUser.totalHours);
  const universityHours = facultyHours.reduce((sum, item) => sum + item[1], 0);
  const approvedCount = state.hourLogs.filter((log) => log.status === "approved").length;
  const stats =
    role === "student"
      ? [
          ["My Total Hours", state.currentUser.totalHours, `${badgeName} social credit badge`],
          ["Upcoming Events", state.events.length, "Open for registration"],
          ["University Total", formatNumber(universityHours), "Approved volunteer hours"],
          ["My Pending Claims", currentUserLogs().filter((log) => log.status === "pending").length, "Awaiting approval"],
        ]
      : [
          ["Pending Approvals", pendingLogs().length, "Need review"],
          ["Published Events", state.events.length, "Across clubs and NGOs"],
          ["Approved Logs", approvedCount, "Verified submissions"],
          ["University Impact", formatNumber(universityHours), "Total approved hours"],
        ];

  return `
    <div class="view-heading">
      <div>
        <h1>${role === "student" ? "Student Dashboard" : `${roleLabel(role)} Dashboard`}</h1>
        <p>Overview of volunteer hours, upcoming events, claims, and participation reports.</p>
      </div>
      <span class="pill ${badgeClass}">${badgeName} Badge</span>
    </div>

    <div class="grid stats-grid">
      ${stats.map(([label, value, note]) => renderStat(label, value, note)).join("")}
    </div>

    <div class="grid dash-grid" style="margin-top: 18px;">
      <div class="grid">
        <div class="panel">
          <h2>Hours by Faculty</h2>
          <p class="panel-subtitle">Which faculties are contributing the most volunteer hours.</p>
          ${renderBarChart(facultyHours)}
        </div>
        <div class="panel">
          <h2>Monthly Hours Trend</h2>
          <p class="panel-subtitle">A six-month view of approved volunteering activity.</p>
          ${renderLineChart(monthlyHours)}
        </div>
      </div>
      <div class="grid">
        <div class="panel">
          <h2>Top 5 Clubs</h2>
          <p class="panel-subtitle">Leaderboard for club impact.</p>
          ${renderBarChart(clubHours)}
        </div>
        <div class="panel">
          <h2>${role === "student" ? "Upcoming Events" : "Pending Approval Summary"}</h2>
          <p class="panel-subtitle">${role === "student" ? "Events students can join next." : "Submissions waiting for club leader or admin action."}</p>
          ${role === "student" ? renderUpcomingEvents() : renderApprovalCards(pendingLogs().slice(0, 3))}
        </div>
      </div>
    </div>
  `;
}

function renderStat(label, value, note) {
  return `
    <div class="stat">
      <span>${label}</span>
      <strong>${value}</strong>
      <em>${note}</em>
    </div>
  `;
}

function renderBarChart(rows) {
  const max = Math.max(...rows.map((row) => row[1]));
  return `
    <div class="bar-chart">
      ${rows
        .map(
          ([label, value]) => `
            <div class="bar-row">
              <div class="bar-label" title="${label}">${label}</div>
              <div class="bar-track"><div class="bar-fill" style="width: ${(value / max) * 100}%"></div></div>
              <div class="bar-value">${value}</div>
            </div>
          `,
        )
        .join("")}
    </div>
  `;
}

function renderLineChart(rows) {
  const max = Math.max(...rows.map((row) => row[1]));
  const min = Math.min(...rows.map((row) => row[1]));
  const width = 620;
  const height = 230;
  const left = 42;
  const top = 24;
  const chartWidth = width - 70;
  const chartHeight = height - 68;
  const points = rows.map(([label, value], index) => {
    const x = left + (chartWidth / (rows.length - 1)) * index;
    const y = top + chartHeight - ((value - min) / (max - min || 1)) * chartHeight;
    return { label, value, x, y };
  });
  const path = points.map((point, index) => `${index ? "L" : "M"} ${point.x} ${point.y}`).join(" ");

  return `
    <div class="trend-chart">
      <svg class="line-chart" viewBox="0 0 ${width} ${height}" role="img" aria-label="Monthly volunteer hours trend">
        <line x1="${left}" y1="${top + chartHeight}" x2="${left + chartWidth}" y2="${top + chartHeight}" stroke="#dbe3ef" stroke-width="2" />
        <line x1="${left}" y1="${top}" x2="${left}" y2="${top + chartHeight}" stroke="#dbe3ef" stroke-width="2" />
        <path d="${path}" fill="none" stroke="#0f8b63" stroke-width="5" stroke-linecap="round" stroke-linejoin="round" />
        ${points
          .map(
            (point) => `
              <circle cx="${point.x}" cy="${point.y}" r="6" fill="#ffffff" stroke="#0f8b63" stroke-width="4" />
              <text x="${point.x}" y="${height - 18}" text-anchor="middle">${point.label}</text>
              <text x="${point.x}" y="${point.y - 13}" text-anchor="middle">${point.value}</text>
            `,
          )
          .join("")}
      </svg>
    </div>
  `;
}

function renderUpcomingEvents() {
  return `
    <div class="event-list">
      ${state.events
        .slice(0, 3)
        .map(
          (event) => `
            <article class="event-card">
              <div>
                <h3>${event.name}</h3>
                <div class="event-meta">
                  <span class="pill">${event.category}</span>
                  <span class="pill green">${formatDate(event.date)}</span>
                  <span class="pill amber">${event.hours} hours</span>
                </div>
              </div>
              <button class="secondary-btn" data-view="events">View</button>
            </article>
          `,
        )
        .join("")}
    </div>
  `;
}

function renderEvents() {
  return `
    <div class="view-heading">
      <div>
        <h1>Volunteer Events</h1>
        <p>Students can browse opportunities and join available events posted by clubs or admins.</p>
      </div>
      ${state.currentUser.role !== "student" ? '<button class="secondary-btn" data-view="manage">Manage Events</button>' : ""}
    </div>
    <div class="panel">
      <div class="table-wrap">
        <table>
          <thead>
            <tr>
              <th>Event</th>
              <th>Category</th>
              <th>Date</th>
              <th>Location</th>
              <th>Hours</th>
              <th>Slots Left</th>
              <th>Action</th>
            </tr>
          </thead>
          <tbody>
            ${state.events.map(renderEventRow).join("")}
          </tbody>
        </table>
      </div>
    </div>
  `;
}

function renderEventRow(event) {
  const joined = state.joinedEventIds.has(event.id);
  const canJoin = state.currentUser.role === "student";
  return `
    <tr>
      <td>
        <strong>${event.name}</strong><br />
        <span class="label">${event.organizer}</span>
      </td>
      <td><span class="pill">${event.category}</span></td>
      <td>${formatDate(event.date)}</td>
      <td>${event.location}</td>
      <td>${event.hours}</td>
      <td>${event.slotsLeft}</td>
      <td>
        ${
          canJoin
            ? `<button class="${joined ? "ghost-btn" : "success-btn"}" data-action="join-event" data-event-id="${event.id}">${joined ? "Joined" : "Join"}</button>`
            : `<button class="secondary-btn" data-view="manage">Edit</button>`
        }
      </td>
    </tr>
  `;
}

function renderHours() {
  if (state.currentUser.role !== "student") {
    return renderAccessNotice("My Hours is a student workflow. Use Pending Approvals to verify submissions.");
  }

  return `
    <div class="view-heading">
      <div>
        <h1>My Hours</h1>
        <p>Submit completed volunteer hours and track approval status.</p>
      </div>
    </div>
    <div class="split">
      <div class="panel form-panel">
        <h2>Submit Hours</h2>
        <p class="panel-subtitle">Claims stay pending until a club leader or admin verifies them.</p>
        <form class="form-grid" data-form="hour-log">
          <div class="field">
            <label for="hour-event">Volunteer Event</label>
            <select id="hour-event" name="eventId" required>
              ${state.events.map((event) => `<option value="${event.id}">${event.name}</option>`).join("")}
            </select>
          </div>
          <div class="field">
            <label for="hour-claimed">Hours Claimed</label>
            <input id="hour-claimed" name="hours" type="number" min="1" max="24" step="0.5" value="4" required />
          </div>
          <div class="field">
            <label for="hour-remarks">Evidence / Remarks</label>
            <textarea id="hour-remarks" name="remarks" placeholder="Attendance sheet, supervisor name, or short evidence note"></textarea>
          </div>
          <button class="primary-btn" type="submit">Submit Claim</button>
        </form>
      </div>
      <div class="panel">
        <h2>Submission History</h2>
        <p class="panel-subtitle">Pending, approved, and rejected logs with approval details.</p>
        ${renderHourHistory(currentUserLogs())}
      </div>
    </div>
  `;
}

function renderHourHistory(logs) {
  if (!logs.length) {
    return renderEmpty("No hour submissions yet.", "Submit your first claim after completing a volunteer event.");
  }

  return `
    <div class="table-wrap">
      <table>
        <thead>
          <tr>
            <th>Event</th>
            <th>Hours</th>
            <th>Submitted</th>
            <th>Status</th>
            <th>Approval Details</th>
            <th>Action</th>
          </tr>
        </thead>
        <tbody>
          ${logs
            .map((log) => {
              const event = eventById(log.eventId);
              return `
                <tr>
                  <td><strong>${event?.name || "Deleted event"}</strong><br /><span class="label">${log.remarks || "No remarks"}</span></td>
                  <td>${log.hours}</td>
                  <td>${formatDate(log.submitted)}</td>
                  <td>${renderStatus(log.status)}</td>
                  <td>${log.approvedBy ? `${log.approvedBy}<br /><span class="label">${formatDate(log.approvedAt)}</span>` : '<span class="label">Waiting for review</span>'}</td>
                  <td>${log.status === "pending" ? `<button class="danger-btn" data-action="cancel-log" data-log-id="${log.id}">Cancel</button>` : '<span class="label">Locked</span>'}</td>
                </tr>
              `;
            })
            .join("")}
        </tbody>
      </table>
    </div>
  `;
}

function renderStatus(status) {
  const statusClass = {
    approved: "green",
    pending: "amber",
    rejected: "red",
  }[status];
  return `<span class="pill ${statusClass}">${status}</span>`;
}

function renderApprovals() {
  if (state.currentUser.role === "student") {
    return renderAccessNotice("Pending Approvals is only available to club leaders and admins.");
  }

  return `
    <div class="view-heading">
      <div>
        <h1>Pending Approvals</h1>
        <p>Review submitted volunteer hour claims, add remarks, and approve or reject them.</p>
      </div>
      <span class="pill amber">${pendingLogs().length} pending</span>
    </div>
    <div class="panel">
      ${pendingLogs().length ? renderApprovalTable(pendingLogs()) : renderEmpty("All caught up.", "There are no hour submissions waiting for verification.")}
    </div>
  `;
}

function renderApprovalCards(logs) {
  if (!logs.length) {
    return renderEmpty("No pending approvals.", "New claims will appear here.");
  }

  return `
    <div class="approval-list">
      ${logs
        .map((log) => {
          const event = eventById(log.eventId);
          return `
            <article class="event-card">
              <div>
                <h3>${log.student}</h3>
                <div class="event-meta">
                  <span class="pill amber">${log.hours} hours</span>
                  <span class="pill">${event?.category || "Event"}</span>
                  <span class="pill green">${event?.name || "Deleted event"}</span>
                </div>
              </div>
              <button class="secondary-btn" data-view="approvals">Review</button>
            </article>
          `;
        })
        .join("")}
    </div>
  `;
}

function renderApprovalTable(logs) {
  return `
    <div class="table-wrap">
      <table>
        <thead>
          <tr>
            <th>Student</th>
            <th>Event</th>
            <th>Hours</th>
            <th>Submitted</th>
            <th>Remarks</th>
            <th>Decision</th>
          </tr>
        </thead>
        <tbody>
          ${logs
            .map((log) => {
              const event = eventById(log.eventId);
              return `
                <tr>
                  <td><strong>${log.student}</strong><br /><span class="label">${log.matric} - ${log.faculty}</span></td>
                  <td><strong>${event?.name || "Deleted event"}</strong><br /><span class="label">${event?.organizer || "Unknown organizer"}</span></td>
                  <td>${log.hours}</td>
                  <td>${formatDate(log.submitted)}</td>
                  <td><input class="table-input" data-remark-input="${log.id}" value="${log.remarks}" /></td>
                  <td>
                    <div class="table-actions">
                      <button class="success-btn" data-action="approve-log" data-log-id="${log.id}">Approve</button>
                      <button class="danger-btn" data-action="reject-log" data-log-id="${log.id}">Reject</button>
                    </div>
                  </td>
                </tr>
              `;
            })
            .join("")}
        </tbody>
      </table>
    </div>
  `;
}

function renderManageEvents() {
  if (state.currentUser.role === "student") {
    return renderAccessNotice("Manage Events is only available to club leaders and admins.");
  }

  const editing = state.events.find((event) => event.id === state.editingEventId);
  return `
    <div class="view-heading">
      <div>
        <h1>Manage Events</h1>
        <p>Create, update, and delete volunteer opportunities for the marketplace.</p>
      </div>
      ${editing ? '<button class="secondary-btn" data-action="clear-event-form">New Event</button>' : ""}
    </div>
    <div class="split">
      <div class="panel form-panel">
        <h2>${editing ? "Edit Event" : "Create Event"}</h2>
        <p class="panel-subtitle">${editing ? "Update the selected opportunity." : "Publish a hardcoded demo event into the current session."}</p>
        <form class="form-grid" data-form="event">
          <div class="field">
            <label for="event-name">Event Name</label>
            <input id="event-name" name="name" value="${editing?.name || ""}" placeholder="Volunteer event title" required />
          </div>
          <div class="form-grid two-col">
            <div class="field">
              <label for="event-category">Category</label>
              <select id="event-category" name="category" required>
                ${["Education", "Environment", "Community", "Health", "Leadership"]
                  .map((category) => `<option ${editing?.category === category ? "selected" : ""}>${category}</option>`)
                  .join("")}
              </select>
            </div>
            <div class="field">
              <label for="event-date">Date</label>
              <input id="event-date" name="date" type="date" value="${editing?.date || "2026-07-20"}" required />
            </div>
          </div>
          <div class="field">
            <label for="event-location">Location</label>
            <input id="event-location" name="location" value="${editing?.location || ""}" placeholder="Event venue" required />
          </div>
          <div class="form-grid two-col">
            <div class="field">
              <label for="event-hours">Hours</label>
              <input id="event-hours" name="hours" type="number" min="1" max="24" value="${editing?.hours || 4}" required />
            </div>
            <div class="field">
              <label for="event-slots">Slots Left</label>
              <input id="event-slots" name="slotsLeft" type="number" min="0" max="500" value="${editing?.slotsLeft || 30}" required />
            </div>
          </div>
          <div class="field">
            <label for="event-organizer">Organizer</label>
            <input id="event-organizer" name="organizer" value="${editing?.organizer || state.currentUser.faculty}" required />
          </div>
          <button class="primary-btn" type="submit">${editing ? "Save Changes" : "Create Event"}</button>
        </form>
      </div>
      <div class="panel">
        <h2>Event Records</h2>
        <p class="panel-subtitle">Prototype CRUD table for club leaders and admins.</p>
        ${renderManageEventsTable()}
      </div>
    </div>
  `;
}

function renderManageEventsTable() {
  return `
    <div class="table-wrap">
      <table>
        <thead>
          <tr>
            <th>Event</th>
            <th>Date</th>
            <th>Hours</th>
            <th>Slots</th>
            <th>Owner</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          ${state.events
            .map(
              (event) => `
                <tr>
                  <td><strong>${event.name}</strong><br /><span class="label">${event.category} - ${event.location}</span></td>
                  <td>${formatDate(event.date)}</td>
                  <td>${event.hours}</td>
                  <td>${event.slotsLeft}</td>
                  <td>${event.owner}</td>
                  <td>
                    <div class="table-actions">
                      <button class="secondary-btn" data-action="edit-event" data-event-id="${event.id}">Edit</button>
                      <button class="danger-btn" data-action="delete-event" data-event-id="${event.id}">Delete</button>
                    </div>
                  </td>
                </tr>
              `,
            )
            .join("")}
        </tbody>
      </table>
    </div>
  `;
}

function renderReports() {
  if (state.currentUser.role === "student") {
    return renderAccessNotice("Reports are available to club leaders and admins.");
  }

  const universityHours = facultyHours.reduce((sum, item) => sum + item[1], 0);
  return `
    <div class="view-heading">
      <div>
        <h1>Report Generation</h1>
        <p>Dashboard-style analysis required in the proposal: faculty hours, top clubs, trends, university impact, and pending approvals.</p>
      </div>
      <span class="pill green">Chart.js style prototype</span>
    </div>
    <div class="grid stats-grid">
      ${renderStat("Total University Impact", formatNumber(universityHours), "Approved hours")}
      ${renderStat("Top Faculty", "CS", "420 verified hours")}
      ${renderStat("Top Club", "Eco Warriors", "188 verified hours")}
      ${renderStat("Pending Summary", pendingLogs().length, "Claims waiting")}
    </div>
    <div class="grid report-grid" style="margin-top: 18px;">
      <div class="panel">
        <h2>Hours by Faculty</h2>
        <p class="panel-subtitle">Bar chart report.</p>
        ${renderBarChart(facultyHours)}
      </div>
      <div class="panel">
        <h2>Top 5 Clubs</h2>
        <p class="panel-subtitle">Club leaderboard report.</p>
        ${renderBarChart(clubHours)}
      </div>
      <div class="panel">
        <h2>Monthly Hours Trend</h2>
        <p class="panel-subtitle">Line chart report.</p>
        ${renderLineChart(monthlyHours)}
      </div>
      <div class="panel">
        <h2>Pending Approvals Summary</h2>
        <p class="panel-subtitle">Operational table for reviewers.</p>
        ${pendingLogs().length ? renderApprovalCards(pendingLogs()) : renderEmpty("No pending approvals.", "Reports update once new claims are submitted.")}
      </div>
    </div>
  `;
}

function renderAccessNotice(title) {
  return `
    <div class="view-heading">
      <div>
        <h1>Access Notice</h1>
        <p>${title}</p>
      </div>
    </div>
    ${renderEmpty("Switch role from the top bar.", "This keeps the demo simple while still showing role-based access control.")}
  `;
}

function renderEmpty(title, message) {
  return `
    <div class="empty-state">
      <strong>${title}</strong>
      <p>${message}</p>
    </div>
  `;
}

function loginAs(role) {
  state.currentUser = { ...demoUsers[role] };
  state.activeView = "dashboard";
  state.editingEventId = null;
  render();
  showToast(`Signed in as ${roleLabel(role)}.`);
}

function handleLogin(form) {
  const value = new FormData(form).get("loginId").toString().toLowerCase();
  const role = value.includes("admin") ? "admin" : value.includes("leader") ? "club_leader" : "student";
  loginAs(role);
}

function handleRegister(form) {
  const data = Object.fromEntries(new FormData(form).entries());
  state.currentUser = {
    name: data.name,
    matric: data.matric,
    email: data.email,
    phone: data.phone,
    faculty: data.faculty,
    role: data.role,
    totalHours: 0,
  };
  state.activeView = "dashboard";
  state.editingEventId = null;
  render();
  showToast("Account created for prototype demo.");
}

function handleHourLog(form) {
  const data = Object.fromEntries(new FormData(form).entries());
  const event = eventById(data.eventId);
  state.hourLogs.unshift({
    id: Date.now(),
    student: state.currentUser.name,
    matric: state.currentUser.matric,
    faculty: state.currentUser.faculty,
    eventId: Number(data.eventId),
    hours: Number(data.hours),
    submitted: today(),
    status: "pending",
    approvedBy: "",
    approvedAt: "",
    remarks: data.remarks || `Claim submitted for ${event?.name || "event"}.`,
  });
  render();
  showToast("Hour claim submitted for approval.");
}

function handleEventForm(form) {
  const data = Object.fromEntries(new FormData(form).entries());
  const payload = {
    name: data.name,
    category: data.category,
    date: data.date,
    location: data.location,
    hours: Number(data.hours),
    slotsLeft: Number(data.slotsLeft),
    organizer: data.organizer,
    owner: data.organizer,
  };

  if (state.editingEventId) {
    state.events = state.events.map((event) =>
      event.id === state.editingEventId ? { ...event, ...payload } : event,
    );
    state.editingEventId = null;
    showToast("Event updated.");
  } else {
    state.events.unshift({ id: Date.now(), ...payload });
    showToast("Event created.");
  }
  render();
}

function updateLogStatus(logId, status) {
  const input = document.querySelector(`[data-remark-input="${logId}"]`);
  const log = state.hourLogs.find((item) => item.id === Number(logId));
  if (!log) return;

  log.status = status;
  log.approvedBy = state.currentUser.name;
  log.approvedAt = today();
  log.remarks = input?.value || log.remarks;

  if (status === "approved" && log.matric === state.currentUser.matric) {
    state.currentUser.totalHours += Number(log.hours);
  }

  render();
  showToast(`Hour claim ${status}.`);
}

document.addEventListener("click", (event) => {
  const target = event.target.closest("button");
  if (!target) return;

  const authMode = target.dataset.authMode;
  if (authMode) {
    state.authMode = authMode;
    render();
    return;
  }

  const loginRole = target.dataset.loginRole;
  if (loginRole) {
    loginAs(loginRole);
    return;
  }

  const view = target.dataset.view;
  if (view) {
    state.activeView = view;
    state.editingEventId = null;
    render();
    return;
  }

  const action = target.dataset.action;
  if (!action) return;

  if (action === "logout") {
    state.currentUser = null;
    state.authMode = "login";
    render();
    showToast("Signed out.");
  }

  if (action === "join-event") {
    const id = Number(target.dataset.eventId);
    if (!state.joinedEventIds.has(id)) {
      state.joinedEventIds.add(id);
      const eventItem = eventById(id);
      if (eventItem && eventItem.slotsLeft > 0) eventItem.slotsLeft -= 1;
      render();
      showToast("Event joined. It now appears as Joined in the marketplace.");
    }
  }

  if (action === "cancel-log") {
    const id = Number(target.dataset.logId);
    state.hourLogs = state.hourLogs.filter((log) => log.id !== id);
    render();
    showToast("Pending hour claim cancelled.");
  }

  if (action === "approve-log" || action === "reject-log") {
    updateLogStatus(target.dataset.logId, action === "approve-log" ? "approved" : "rejected");
  }

  if (action === "edit-event") {
    state.editingEventId = Number(target.dataset.eventId);
    state.activeView = "manage";
    render();
  }

  if (action === "delete-event") {
    const id = Number(target.dataset.eventId);
    state.events = state.events.filter((item) => item.id !== id);
    state.hourLogs = state.hourLogs.map((log) => (log.eventId === id ? { ...log, eventId: 0 } : log));
    render();
    showToast("Event deleted from prototype data.");
  }

  if (action === "clear-event-form") {
    state.editingEventId = null;
    render();
  }
});

document.addEventListener("submit", (event) => {
  event.preventDefault();
  const form = event.target;
  const formType = form.dataset.form;
  if (formType === "login") handleLogin(form);
  if (formType === "register") handleRegister(form);
  if (formType === "hour-log") handleHourLog(form);
  if (formType === "event") handleEventForm(form);
});

document.addEventListener("change", (event) => {
  if (event.target.matches("[data-role-switch]")) {
    loginAs(event.target.value);
  }
});

render();
