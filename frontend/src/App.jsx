import { useEffect, useState } from "react";
import { api } from "./api";
import TestRun from "./TestRun";

const ROLE = {
  admin: "Администратор",
  manager: "Менеджер",
  mentor: "Преподаватель",
  user: "Слушатель",
};

export default function App() {
  const [user, setUser] = useState(undefined);
  const [error, setError] = useState("");

  useEffect(() => {
    let active = true;
    api("/api/session")
      .then((current) => {
        if (active) {
          setUser(current);
        }
      })
      .catch((cause) => {
        if (!active) {
          return;
        }
        if (cause.status === 401) {
          setUser(null);
          return;
        }
        setError(cause.message);
      });
    return () => {
      active = false;
    };
  }, []);

  async function logout() {
    await api("/api/session", { method: "DELETE" });
    setUser(null);
  }

  if (error && user === undefined) {
    return <main className="app"><p className="error">{error}</p></main>;
  }
  if (user === undefined) {
    return <main className="app"><p>Загрузка…</p></main>;
  }
  if (!user) {
    return <Login onSuccess={setUser} />;
  }
  return (
    <main className="app-shell">
      <header className="app-header">
        <div className="brand">
          <span className="brand-mark" aria-hidden="true">
            <img src="/galaktika-logo.svg" alt="" />
          </span>
          <div>
            <strong>Центр развития компетенций</strong>
            <span>Учебный портал</span>
          </div>
        </div>
        <div className="user-menu">
          <div className="user-copy">
            <strong>{user.lastName} {user.firstName}</strong>
            <span>{ROLE[user.role] ?? user.role}</span>
          </div>
          <span className="avatar" aria-hidden="true">{user.firstName?.[0]}{user.lastName?.[0]}</span>
          <button className="ghost-button" type="button" onClick={logout}>Выйти</button>
        </div>
      </header>
      <div className="page-content">
        {user.role === "admin" && <AdminCabinet />}
        {user.role === "manager" && <ManagerCabinet />}
        {user.role === "mentor" && <MentorCabinet />}
        {user.role === "user" && <ListenerCabinet />}
      </div>
    </main>
  );
}

function Login({ onSuccess }) {
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [busy, setBusy] = useState(false);

  async function submit(event) {
    event.preventDefault();
    setBusy(true);
    setError("");
    try {
      onSuccess(await api("/api/session", {
        method: "POST",
        body: JSON.stringify({ username, password }),
      }));
    } catch (cause) {
      setError(cause.message);
    } finally {
      setBusy(false);
    }
  }

  return (
    <main className="login-page">
      <section className="login-intro">
        <div className="brand brand-light">
          <span className="brand-mark" aria-hidden="true">
            <img src="/galaktika-logo.svg" alt="" />
          </span>
          <div>
            <strong>Центр развития компетенций</strong>
            <span>Учебный портал</span>
          </div>
        </div>
        <div className="login-message">
          <p className="eyebrow light">Корпоративное обучение</p>
          <h1>Знания, подтверждённые результатом</h1>
          <p>Единое пространство для назначения, прохождения и контроля аттестаций.</p>
        </div>
      </section>
      <form className="login-card" onSubmit={submit}>
        <p className="eyebrow">Добро пожаловать</p>
        <h2>Вход в систему</h2>
        <p className="login-hint">Используйте учётную запись учебного центра.</p>
        <div className="fields">
          <label>
            Логин
            <input
              type="text"
              value={username}
              onChange={(event) => setUsername(event.target.value)}
              autoComplete="username"
              required
            />
          </label>
          <label>
            Пароль
            <input
              type="password"
              value={password}
              onChange={(event) => setPassword(event.target.value)}
              autoComplete="current-password"
              required
            />
          </label>
        </div>
        {error && <p className="error">{error}</p>}
        <button className="primary login-submit" type="submit" disabled={busy}>Войти в систему</button>
        <div className="demo-note">
          <strong>Демонстрационный доступ</strong>
          <span>Пароль: 1 · Логины: admin, manager, mentor, user</span>
        </div>
      </form>
    </main>
  );
}

function AdminCabinet() {
  const [listeners, setListeners] = useState(null);
  const [error, setError] = useState("");

  useEffect(() => {
    api("/api/listeners").then(setListeners).catch((cause) => setError(cause.message));
  }, []);

  return (
    <>
      <PageTitle eyebrow="Администрирование" title="Слушатели" description="Пользователи учебного центра и данные их профилей." />
      <section className="panel">
      <div className="panel-heading">
        <div><h2>Реестр слушателей</h2><p>{listeners?.length ?? 0} пользователей</p></div>
      </div>
      {error && <p className="error">{error}</p>}
      {!listeners && !error && <p>Загрузка…</p>}
      {listeners && listeners.length === 0 && <p className="hint">Слушателей пока нет.</p>}
      {listeners && listeners.length > 0 && (
        <div className="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Логин</th>
                <th>Слушатель</th>
                <th>Почта</th>
                <th>Организация</th>
                <th>Подразделение</th>
              </tr>
            </thead>
            <tbody>
              {listeners.map((listener) => (
                <tr key={listener.username}>
                  <td>{listener.username}</td>
                  <td>{listener.lastName} {listener.firstName}</td>
                  <td>{listener.email}</td>
                  <td>{listener.institution}</td>
                  <td>{listener.department}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
      </section>
    </>
  );
}

function ManagerCabinet() {
  const [listeners, setListeners] = useState([]);
  const [tests, setTests] = useState([]);
  const [assignments, setAssignments] = useState([]);
  const [attempts, setAttempts] = useState([]);
  const [username, setUsername] = useState("");
  const [testCode, setTestCode] = useState("");
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");
  const [busy, setBusy] = useState(false);

  async function load() {
    const [listenerRows, testRows, assignmentRows, attemptRows] = await Promise.all([
      api("/api/listeners"),
      api("/api/tests"),
      api("/api/assignments"),
      api("/api/reports/attempts"),
    ]);
    setListeners(listenerRows);
    setTests(testRows);
    setAssignments(assignmentRows);
    setAttempts(attemptRows);
    setUsername((current) => current || listenerRows[0]?.username || "");
    setTestCode((current) => current || testRows[0]?.code || "");
  }

  useEffect(() => {
    load().catch((cause) => setError(cause.message));
  }, []);

  async function assign(event) {
    event.preventDefault();
    setBusy(true);
    setError("");
    setMessage("");
    try {
      await api("/api/assignments", {
        method: "POST",
        body: JSON.stringify({ username, testCode }),
      });
      setMessage("Тест назначен");
      await load();
    } catch (cause) {
      setError(cause.message);
    } finally {
      setBusy(false);
    }
  }

  return (
    <>
      <PageTitle eyebrow="Управление обучением" title="Аттестации" description="Назначайте тесты и отслеживайте результаты слушателей." />
      <section className="panel assign-panel">
        <div className="panel-heading">
          <div><h2>Новое назначение</h2><p>Выберите слушателя и программу проверки знаний.</p></div>
        </div>
        <form className="assign-form" onSubmit={assign}>
          <label>
            Слушатель
            <select value={username} onChange={(event) => setUsername(event.target.value)} required>
              {listeners.map((listener) => (
                <option key={listener.username} value={listener.username}>
                  {listener.lastName} {listener.firstName} ({listener.username})
                </option>
              ))}
            </select>
          </label>
          <label>
            Тест
            <select value={testCode} onChange={(event) => setTestCode(event.target.value)} required>
              {tests.map((test) => (
                <option key={test.code} value={test.code}>
                  {test.title} · {test.mentor}
                </option>
              ))}
            </select>
          </label>
          {message && <p className="ok">{message}</p>}
          {error && <p className="error">{error}</p>}
          <button className="primary assign-button" type="submit" disabled={busy}>Назначить тест</button>
        </form>
      </section>
      <section className="panel stack">
        <div className="panel-heading"><div><h2>Назначения</h2><p>Текущие и завершённые аттестации</p></div></div>
        <AssignmentTable rows={assignments} />
        <div className="section-divider" />
        <div className="panel-heading"><div><h2>Последние результаты</h2><p>История завершённых попыток</p></div></div>
        <AttemptTable rows={attempts} showListener />
      </section>
    </>
  );
}

function MentorCabinet() {
  const [tests, setTests] = useState(null);
  const [error, setError] = useState("");

  useEffect(() => {
    api("/api/mentor/tests").then(setTests).catch((cause) => setError(cause.message));
  }, []);

  return (
    <>
      <PageTitle eyebrow="Преподаватель" title="Мои тесты" description="Сводка результатов по закреплённым программам." />
      {tests && tests.length > 0 && (
        <div className="stats-grid">
          <StatCard label="Программ" value={tests.length} tone="blue" />
          <StatCard label="Успешных попыток" value={tests.reduce((sum, test) => sum + test.passedCount, 0)} tone="green" />
          <StatCard label="Требуют внимания" value={tests.reduce((sum, test) => sum + test.failedCount, 0)} tone="red" />
        </div>
      )}
      <section className="panel">
      <div className="panel-heading"><div><h2>Результаты по программам</h2><p>Сводная статистика прохождения</p></div></div>
      {error && <p className="error">{error}</p>}
      {tests && tests.length === 0 && <p className="hint">За вами не закреплено ни одного теста.</p>}
      {tests && tests.length > 0 && (
        <div className="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Тест</th>
                <th>Удачные</th>
                <th>Неудачные</th>
              </tr>
            </thead>
            <tbody>
              {tests.map((test) => (
                <tr key={test.code}>
                  <td>{test.title}</td>
                  <td>{test.passedCount}</td>
                  <td>{test.failedCount}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
      </section>
    </>
  );
}

function ListenerCabinet() {
  const [assignments, setAssignments] = useState([]);
  const [attempts, setAttempts] = useState([]);
  const [session, setSession] = useState(null);
  const [error, setError] = useState("");
  const [busyId, setBusyId] = useState("");

  async function load() {
    const [assignmentRows, attemptRows] = await Promise.all([
      api("/api/my/assignments"),
      api("/api/my/attempts"),
    ]);
    setAssignments(assignmentRows);
    setAttempts(attemptRows);
  }

  useEffect(() => {
    load().catch((cause) => setError(cause.message));
  }, []);

  async function openAssignment(assignment) {
    setBusyId(assignment.id);
    setError("");
    try {
      const next = assignment.activeAttemptId
        ? await api(`/api/attempts/${assignment.activeAttemptId}`)
        : await api("/api/attempts", {
          method: "POST",
          body: JSON.stringify({ assignmentId: assignment.id }),
        });
      setSession(next);
    } catch (cause) {
      setError(cause.message);
    } finally {
      setBusyId("");
    }
  }

  if (session) {
    return (
      <TestRun
        session={session}
        onExit={() => {
          setSession(null);
          load().catch((cause) => setError(cause.message));
        }}
      />
    );
  }

  return (
    <>
      <PageTitle eyebrow="Личный кабинет" title="Моя аттестация" description="Назначенные тесты и история ваших результатов." />
      <section className="panel">
      {error && <p className="error">{error}</p>}
      <div className="panel-heading"><div><h2>Назначенные тесты</h2><p>Доступные программы проверки знаний</p></div></div>
      {assignments.length === 0 && <div className="empty-state"><strong>Нет активных назначений</strong><span>Новые тесты появятся здесь после назначения менеджером.</span></div>}
      {assignments.length > 0 && (
        <ul className="assignment-list">
          {assignments.map((assignment) => (
            <li key={assignment.id}>
              <span>{assignment.testTitle}</span>
              <button
                className="primary"
                type="button"
                disabled={busyId === assignment.id}
                onClick={() => openAssignment(assignment)}
              >
                {assignment.activeAttemptId ? "Продолжить" : "Пройти"}
              </button>
            </li>
          ))}
        </ul>
      )}
      <div className="section-divider" />
      <div className="panel-heading"><div><h2>История попыток</h2><p>Ваши предыдущие результаты</p></div></div>
      <AttemptTable rows={attempts} />
      </section>
    </>
  );
}

function PageTitle({ eyebrow, title, description }) {
  return (
    <header className="page-title">
      <p className="eyebrow">{eyebrow}</p>
      <h1>{title}</h1>
      <p>{description}</p>
    </header>
  );
}

function StatCard({ label, value, tone }) {
  return (
    <div className={`stat-card ${tone}`}>
      <span>{label}</span>
      <strong>{value}</strong>
    </div>
  );
}

function AssignmentTable({ rows }) {
  if (rows.length === 0) {
    return <p className="hint">Назначений пока нет.</p>;
  }
  return (
    <div className="table-wrap">
      <table>
        <thead>
          <tr>
            <th>Слушатель</th>
            <th>Тест</th>
            <th>Дата</th>
            <th>Статус</th>
          </tr>
        </thead>
        <tbody>
          {rows.map((row) => (
            <tr key={row.id}>
              <td>{row.listenerName}</td>
              <td>{row.testTitle}</td>
              <td>{formatDate(row.assignedAt)}</td>
              <td><span className={`status ${row.finished ? "complete" : "pending"}`}>{row.finished ? "Завершено" : "Ожидает"}</span></td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

function AttemptTable({ rows, showListener = false }) {
  if (rows.length === 0) {
    return <p className="hint">Попыток пока нет.</p>;
  }
  return (
    <div className="table-wrap">
      <table>
        <thead>
          <tr>
            {showListener && <th>Слушатель</th>}
            <th>Тест</th>
            <th>Дата</th>
            <th>Результат</th>
          </tr>
        </thead>
        <tbody>
          {rows.map((row) => (
            <tr key={`${row.listenerName}-${row.finishedAt}-${row.testTitle}`}>
              {showListener && <td>{row.listenerName}</td>}
              <td>{row.testTitle}</td>
              <td>{formatDate(row.finishedAt)}</td>
              <td><span className={`status ${row.passed ? "success" : "danger"}`}>{resultLabel(row)}</span></td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

function resultLabel(row) {
  return `${row.scorePercent} из 100 · ${row.passed ? "сдана" : "не сдана"}`;
}

function formatDate(value) {
  return new Intl.DateTimeFormat("ru-RU", {
    dateStyle: "short",
    timeStyle: "short",
  }).format(new Date(value));
}
