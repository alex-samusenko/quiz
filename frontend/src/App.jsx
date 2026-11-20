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
  const [loginNotice, setLoginNotice] = useState("");

  useEffect(() => {
    let active = true;
    api("/api/session", { notifyUnauthorized: false })
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

  useEffect(() => {
    function sessionExpired() {
      setError("");
      setLoginNotice("Сессия завершена. Войдите в систему снова.");
      setUser(null);
    }
    window.addEventListener("app:session-expired", sessionExpired);
    return () => window.removeEventListener("app:session-expired", sessionExpired);
  }, []);

  useEffect(() => {
    if (!user) return undefined;
    let active = true;
    async function verifySession() {
      try {
        const current = await api("/api/session");
        if (active) setUser(current);
      } catch (cause) {
        if (active && cause.status !== 401) setError(cause.message);
      }
    }
    function checkVisibleSession() {
      if (document.visibilityState === "visible") verifySession();
    }
    const timer = setInterval(verifySession, 30000);
    document.addEventListener("visibilitychange", checkVisibleSession);
    window.addEventListener("focus", verifySession);
    return () => {
      active = false;
      clearInterval(timer);
      document.removeEventListener("visibilitychange", checkVisibleSession);
      window.removeEventListener("focus", verifySession);
    };
  }, [user?.username]);

  async function logout() {
    await api("/api/session", { method: "DELETE" });
    setLoginNotice("");
    setUser(null);
  }

  if (error && user === undefined) {
    return <main className="app"><p className="error">{error}</p></main>;
  }
  if (user === undefined) {
    return <main className="app"><p>Загрузка…</p></main>;
  }
  if (!user) {
    return <Login notice={loginNotice} onSuccess={(current) => {
      setLoginNotice("");
      setUser(current);
    }} />;
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

function Login({ onSuccess, notice }) {
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [busy, setBusy] = useState(false);
  const [emulatorEnabled, setEmulatorEnabled] = useState(false);

  useEffect(() => {
    api("/api/moodle/config", { notifyUnauthorized: false })
      .then((config) => setEmulatorEnabled(config.emulatorEnabled))
      .catch(() => setEmulatorEnabled(false));
  }, []);

  async function submit(event) {
    event.preventDefault();
    setBusy(true);
    setError("");
    try {
      onSuccess(await api("/api/session", {
        method: "POST",
        body: JSON.stringify({ username, password }),
        notifyUnauthorized: false,
      }));
    } catch (cause) {
      setError(cause.message);
    } finally {
      setBusy(false);
    }
  }

  async function emulate(username) {
    setBusy(true);
    setError("");
    try {
      onSuccess(await api("/api/moodle/emulator/launch", {
        method: "POST",
        body: JSON.stringify({ username }),
        notifyUnauthorized: false,
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
        {notice && <p className="session-notice">{notice}</p>}
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
        {emulatorEnabled && (
          <div className="moodle-emulator">
            <strong>Эмулятор Moodle</strong>
            <span>Проверка доверенного перехода без отдельного сервера Moodle</span>
            <div className="emulator-actions">
              {[["admin", "Администратор"], ["manager", "Менеджер"], ["mentor", "Преподаватель"], ["user", "Слушатель"]]
                .map(([login, label]) => (
                  <button className="secondary" type="button" disabled={busy} key={login}
                    onClick={() => emulate(login)}>{label}</button>
                ))}
            </div>
          </div>
        )}
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
  const [tests, setTests] = useState([]);
  const [assignments, setAssignments] = useState([]);
  const [attempts, setAttempts] = useState([]);
  const [activeAttempts, setActiveAttempts] = useState([]);
  const [moodleIntegration, setMoodleIntegration] = useState(null);
  const [selectedListeners, setSelectedListeners] = useState([]);
  const [listenerQuery, setListenerQuery] = useState("");
  const [listenerSuggestions, setListenerSuggestions] = useState([]);
  const [listenerSearchBusy, setListenerSearchBusy] = useState(false);
  const [testCode, setTestCode] = useState("");
  const [level, setLevel] = useState("SPECIALIST");
  const initialStart = toMoscowInput(new Date());
  const initialEnd = toMoscowInput(new Date(Date.now() + 30 * 24 * 60 * 60 * 1000));
  const [startsAt, setStartsAt] = useState(initialStart);
  const [endsAt, setEndsAt] = useState(initialEnd);
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");
  const [busy, setBusy] = useState(false);

  async function load() {
    const [testRows, assignmentRows, attemptRows, activeRows] = await Promise.all([
      api("/api/tests"),
      api("/api/manager/assignments"),
      api("/api/reports/attempts"),
      api("/api/manager/active-attempts"),
    ]);
    setTests(testRows);
    setAssignments(assignmentRows);
    setAttempts(attemptRows);
    setActiveAttempts(activeRows);
    setTestCode((current) => current || testRows[0]?.code || "");
  }

  useEffect(() => {
    load().catch((cause) => setError(cause.message));
    api("/api/manager/moodle-integration").then(setMoodleIntegration).catch(() => {});
    const monitor = setInterval(() => {
      api("/api/manager/active-attempts").then(setActiveAttempts).catch((cause) => setError(cause.message));
    }, 5000);
    return () => clearInterval(monitor);
  }, []);

  useEffect(() => {
    const query = listenerQuery.trim();
    if (query.length < 2) {
      setListenerSuggestions([]);
      setListenerSearchBusy(false);
      return undefined;
    }
    let active = true;
    setListenerSearchBusy(true);
    const timer = setTimeout(() => {
      api(`/api/manager/listeners/search?q=${encodeURIComponent(query)}`)
        .then((rows) => {
          if (active) setListenerSuggestions(rows.filter((row) => !selectedListeners.some((item) => item.username === row.username)));
        })
        .catch((cause) => { if (active) setError(cause.message); })
        .finally(() => { if (active) setListenerSearchBusy(false); });
    }, 250);
    return () => {
      active = false;
      clearTimeout(timer);
    };
  }, [listenerQuery, selectedListeners]);

  async function assign(event) {
    event.preventDefault();
    setBusy(true);
    setError("");
    setMessage("");
    try {
      const created = await api("/api/manager/assignments", {
        method: "POST",
        body: JSON.stringify({
          usernames: selectedListeners.map((listener) => listener.username),
          testCode,
          level,
          startsAt: toMoscowIso(startsAt),
          endsAt: toMoscowIso(endsAt),
          accessFrom: toMoscowIso(startsAt),
          accessUntil: toMoscowIso(endsAt),
        }),
      });
      const warnings = created.map((row) => row.timezoneWarning).filter(Boolean);
      setMessage(`Создано назначений: ${created.length}${warnings.length ? `. ${warnings.join("; ")}` : ""}`);
      setSelectedListeners([]);
      setListenerQuery("");
      await load();
    } catch (cause) {
      setError(cause.message);
    } finally {
      setBusy(false);
    }
  }

  function addListener(listener) {
    setSelectedListeners((current) => current.some((item) => item.username === listener.username)
      ? current
      : [...current, listener]);
    setListenerQuery("");
    setListenerSuggestions([]);
  }

  function removeListener(username) {
    setSelectedListeners((current) => current.filter((listener) => listener.username !== username));
  }

  async function cancelAssignment(id) {
    setBusy(true);
    setError("");
    try {
      await api(`/api/manager/assignments/${id}/cancel`, { method: "POST" });
      setMessage("Назначение отменено");
      await load();
    } catch (cause) {
      setError(cause.message);
    } finally {
      setBusy(false);
    }
  }

  async function resume(attemptId) {
    setBusy(true);
    setError("");
    try {
      await api(`/api/manager/attempts/${attemptId}/resume`, { method: "POST" });
      setMessage("Попытка возобновлена");
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
        <form className="assign-form assignment-window-form" onSubmit={assign}>
          <div className="listener-selector">
            <label htmlFor="listener-search">Слушатели</label>
            <div className="selected-listeners" aria-live="polite">
              {selectedListeners.length === 0 && <span className="selected-placeholder">Выбранные слушатели появятся здесь</span>}
              {selectedListeners.map((listener) => (
                <span className="listener-chip" key={listener.username}>
                  <span>{listener.lastName} {listener.firstName}</span>
                  <small>{listener.email || listener.username}</small>
                  <button type="button" aria-label={`Удалить ${listener.lastName} ${listener.firstName}`} onClick={() => removeListener(listener.username)}>×</button>
                </span>
              ))}
            </div>
            <div className="listener-search-box">
              <input id="listener-search" type="text" value={listenerQuery} onChange={(event) => setListenerQuery(event.target.value)} placeholder="Начните вводить фамилию или имя" autoComplete="off" />
              {listenerQuery.trim().length >= 2 && (
                <div className="listener-suggestions">
                  {listenerSearchBusy && <p>Поиск…</p>}
                  {!listenerSearchBusy && listenerSuggestions.length === 0 && <p>Совпадений не найдено</p>}
                  {!listenerSearchBusy && listenerSuggestions.map((listener) => (
                    <button type="button" key={listener.username} onClick={() => addListener(listener)}>
                      <strong>{listener.lastName} {listener.firstName}</strong>
                      <span>{listener.email || listener.username}</span>
                    </button>
                  ))}
                </div>
              )}
            </div>
            <small className="selection-count">Выбрано: {selectedListeners.length}</small>
          </div>
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
          <label>
            Уровень аттестации
            <select value={level} onChange={(event) => setLevel(event.target.value)} required>
              <option value="SPECIALIST">Специалист</option>
              <option value="EXPERT">Эксперт</option>
            </select>
          </label>
          <label>Доступно с<input type="datetime-local" value={startsAt} onChange={(event) => setStartsAt(event.target.value)} required /></label>
          <label>Доступно до<input type="datetime-local" value={endsAt} onChange={(event) => setEndsAt(event.target.value)} required /></label>
          {message && <p className="ok">{message}</p>}
          {error && <p className="error">{error}</p>}
          <button className="primary assign-button" type="submit" disabled={busy || selectedListeners.length === 0}>Назначить выбранным</button>
        </form>
      </section>
      <section className="panel stack">
        <div className="panel-heading"><div><h2>Назначения</h2><p>Текущие и завершённые аттестации</p></div></div>
        <AssignmentTable rows={assignments} busy={busy} onCancel={cancelAssignment} />
        <div className="section-divider" />
        <div className="panel-heading"><div><h2>Активные попытки</h2><p>Контроль связи и приостановленных экзаменов</p></div></div>
        <ActiveAttemptTable rows={activeAttempts} busy={busy} onResume={resume} />
        <div className="section-divider" />
        <div className="panel-heading"><div><h2>Последние результаты</h2><p>История завершённых попыток</p></div></div>
        <AttemptTable rows={attempts} showListener />
      </section>
      {moodleIntegration?.enabled && (
        <section className="panel stack">
          <div className="panel-heading"><div><h2>Банки Moodle</h2><p>{moodleIntegration.status} · Moodle {moodleIntegration.release}</p></div></div>
          {moodleIntegration.banks.length === 0 && <p className="hint">Отмеченные банки аттестации не найдены.</p>}
          {moodleIntegration.banks.map((bank) => (
            <article className="appeal-card" key={bank.code}>
              <strong>{bank.courseName} · {bank.name}</strong>
              <p>Код: {bank.code}</p>
              <p>Вопросов: {bank.questions}; автоматических: {bank.automaticQuestions}; лёгких: {bank.easy}; средних: {bank.medium}; сложных: {bank.hard}</p>
            </article>
          ))}
        </section>
      )}
    </>
  );
}

function ActiveAttemptTable({ rows, busy, onResume }) {
  if (rows.length === 0) {
    return <p className="hint">Активных попыток пока нет.</p>;
  }
  return (
    <div className="table-wrap">
      <table>
        <thead><tr><th>Слушатель</th><th>Тест</th><th>Осталось</th><th>Состояние</th><th /></tr></thead>
        <tbody>
          {rows.map((row) => (
            <tr key={row.id}>
              <td>{row.listenerName}</td>
              <td>{row.testTitle}</td>
              <td>{formatDuration(row.remainingSeconds)}</td>
              <td><span className={`status ${row.paused ? "danger" : "success"}`}>{row.paused ? "Пауза" : "Выполняется"}</span></td>
              <td>{row.paused && <button className="secondary" type="button" disabled={busy} onClick={() => onResume(row.id)}>Возобновить</button>}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

function formatDuration(totalSeconds) {
  const hours = Math.floor(totalSeconds / 3600);
  const minutes = Math.floor((totalSeconds % 3600) / 60);
  const seconds = totalSeconds % 60;
  return `${String(hours).padStart(2, "0")}:${String(minutes).padStart(2, "0")}:${String(seconds).padStart(2, "0")}`;
}

function MentorCabinet() {
  const [tests, setTests] = useState(null);
  const [attempts, setAttempts] = useState([]);
  const [appeals, setAppeals] = useState([]);
  const [review, setReview] = useState(null);
  const [reviewAttempt, setReviewAttempt] = useState(null);
  const [error, setError] = useState("");

  useEffect(() => {
    Promise.all([api("/api/mentor/tests"), api("/api/mentor/attempts"), api("/api/mentor/appeals")])
      .then(([testRows, attemptRows, appealRows]) => { setTests(testRows); setAttempts(attemptRows); setAppeals(appealRows); })
      .catch((cause) => setError(cause.message));
  }, []);

  async function openReview(attempt) {
    try { setReview(await api(`/api/attempts/${attempt.id}/mentor-review`)); setReviewAttempt(attempt); }
    catch (cause) { setError(cause.message); }
  }

  if (review) return <AttemptReview review={review} onExit={() => setReview(null)} editable={Boolean(reviewAttempt?.appealStatus)} attemptId={reviewAttempt?.id} onChange={setReview} />;

  async function resolveAppeal(appeal, decision) {
    const explanation = window.prompt("Пояснение к решению:");
    if (!explanation) return;
    let score = null;
    if (decision === "CHANGE_SCORE") {
      const value = window.prompt("Новый балл от 0 до 100:", String(appeal.originalScore));
      if (value == null) return;
      score = Number(value);
    }
    try {
      await api(`/api/mentor/appeals/${appeal.id}/resolve`, { method: "POST", body: JSON.stringify({ decision, score, explanation }) });
      setAppeals(await api("/api/mentor/appeals"));
    } catch (cause) { setError(cause.message); }
  }

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
      <section className="panel">
        <div className="panel-heading"><div><h2>Результаты слушателей</h2><p>До апелляции доступны только для просмотра</p></div></div>
        <AttemptTable rows={attempts} showListener onReview={openReview} mentor />
      </section>
      <section className="panel stack">
        <div className="panel-heading"><div><h2>Апелляции</h2><p>Обращения по неудачным попыткам</p></div></div>
        {appeals.length === 0 && <p className="hint">Новых апелляций нет.</p>}
        {appeals.map((appeal) => (
          <article className="appeal-card" key={appeal.id}>
            <strong>{appeal.listenerName} · {appeal.testTitle}</strong>
            <p><b>Вопрос:</b> {appeal.questionReference}</p><p><b>Пример:</b> {appeal.exampleDescription}</p>
            <p><b>Позиция:</b> {appeal.interpretation}</p>
            {appeal.legalReference && <p><b>Нормативная ссылка:</b> {appeal.legalReference}</p>}
            <a download={appeal.attachmentName} href={`data:${appeal.attachmentType};base64,${appeal.attachmentBase64}`}>{appeal.attachmentName}</a>
            {appeal.status === "SUBMITTED" ? <div className="actions"><button className="secondary" onClick={() => resolveAppeal(appeal, "REJECT")}>Отклонить</button><button className="primary" onClick={() => resolveAppeal(appeal, "CHANGE_SCORE")}>Изменить балл</button></div>
              : <p className="hint">Решение: {appeal.resolution}{appeal.changedScore != null ? ` · ${appeal.changedScore} баллов` : ""}</p>}
          </article>
        ))}
      </section>
    </>
  );
}

function ListenerCabinet() {
  const [assignments, setAssignments] = useState([]);
  const [attempts, setAttempts] = useState([]);
  const [session, setSession] = useState(null);
  const [review, setReview] = useState(null);
  const [appealAttempt, setAppealAttempt] = useState(null);
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

  async function openReview(attempt) {
    setBusyId(attempt.id);
    setError("");
    try {
      setReview(await api(`/api/attempts/${attempt.id}/review`));
    } catch (cause) {
      setError(cause.message);
      load().catch(() => {});
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


  if (review) {
    return <AttemptReview review={review} onExit={() => setReview(null)} />;
  }
  if (appealAttempt) {
    return <AppealForm attempt={appealAttempt} onExit={() => { setAppealAttempt(null); load().catch(() => {}); }} />;
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
              <span>
                <strong>{assignment.testTitle}</strong>
                <small>{levelTitle(assignment.level)} · {assignment.status} · {formatDate(assignment.accessFrom)} — {formatDate(assignment.accessUntil)}</small>
              </span>
              <button
                className="primary"
                type="button"
                disabled={busyId === assignment.id || (!assignment.available && !assignment.activeAttemptId)}
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
      <AttemptTable rows={attempts} busyId={busyId} onReview={openReview} onAppeal={setAppealAttempt} />
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

function AssignmentTable({ rows, busy, onCancel }) {
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
            <th>Окно доступности</th>
            <th>Статус</th>
            <th />
          </tr>
        </thead>
        <tbody>
          {rows.map((row) => (
            <tr key={row.id}>
              <td>{row.listenerName}</td>
              <td>{row.testTitle}<br /><small>{levelTitle(row.level)}</small></td>
              <td>{formatDate(row.accessFrom)}<br />{formatDate(row.accessUntil)}</td>
              <td><span className={`status ${statusTone(row.status)}`}>{row.status}</span></td>
              <td>{["Запланировано", "Доступно"].includes(row.status) && (
                <button className="secondary" type="button" disabled={busy} onClick={() => onCancel(row.id)}>Отменить</button>
              )}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

function statusTone(status) {
  if (status === "Завершено") return "complete";
  if (status === "Выполняется" || status === "Доступно") return "success";
  if (status === "Отменено" || status === "Просрочено") return "danger";
  return "pending";
}

function levelTitle(level) {
  return level === "EXPERT" ? "Эксперт" : "Специалист";
}

function AttemptTable({ rows, showListener = false, busyId = "", onReview, onAppeal, mentor = false }) {
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
            {(!showListener || mentor) && <th />}
          </tr>
        </thead>
        <tbody>
          {rows.map((row) => (
            <tr key={`${row.listenerName}-${row.finishedAt}-${row.testTitle}`}>
              {showListener && <td>{row.listenerName}</td>}
              <td>{row.testTitle}</td>
              <td>{formatDate(row.finishedAt)}</td>
              <td><span className={`status ${row.passed ? "success" : "danger"}`}>{resultLabel(row)}</span></td>
              {mentor && <td>{row.reviewDataAvailable && <button className="secondary" type="button" onClick={() => onReview(row)}>Просмотреть</button>}</td>}
              {!showListener && <td>{row.reviewDataAvailable && new Date(row.reviewUntil) > new Date() && (
                <button className="secondary" type="button" disabled={busyId === row.id} onClick={() => onReview(row)}>Разбор</button>
              )} {!showListener && row.scorePercent < 80 && !row.appealStatus && new Date(row.reviewUntil) > new Date() && (
                <button className="secondary" type="button" onClick={() => onAppeal(row)}>Апелляция</button>
              )}</td>}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

function AttemptReview({ review, onExit, editable = false, attemptId, onChange }) {
  async function changeAnswer(answer, number) {
    const question = review.questions[answer.index];
    const selected = question.choiceType === "MULTIPLE"
      ? (answer.selected.includes(number) ? answer.selected.filter((value) => value !== number) : [...answer.selected, number])
      : [number];
    onChange(await api(`/api/attempts/${attemptId}/mentor-answers`, { method: "PUT", body: JSON.stringify({ questionIndex: answer.index, selected }) }));
  }
  return (
    <section className="panel test-panel">
      <p className="eyebrow">Разбор попытки</p>
      <h1>{review.testTitle}</h1>
      <p className="result-score">{review.scorePercent} из 100</p>
      <p className="hint">Правильных ответов: {review.rightAnswersCount} из {review.questionsCount}. Разбор доступен до {formatDate(review.reviewUntil)}.</p>
      <p className="actions review-top-actions"><button className="primary" type="button" onClick={onExit}>Вернуться в кабинет</button></p>
      {review.answers.length === 0 && (
        <div className="empty-state review-empty">
          <strong>Нет ответов для разбора</strong>
          <span>В этой попытке слушатель не выбрал ни одного варианта ответа.</span>
        </div>
      )}
      {review.answers.length > 0 && (
        <ul className="mistakes">
          {review.answers.map((answer) => {
            const question = review.questions[answer.index];
            return (
              <li key={answer.index}>
                <span className={`status ${answer.correctAnswer ? "success" : "danger"}`}>{answer.correctAnswer ? "Верно" : "Ошибка"}</span>
                <strong>{answer.text}</strong>
                {editable ? <fieldset className="review-options"><legend>Ответ слушателя</legend>{question.options.map((option, index) => <label key={option}><input type={question.choiceType === "MULTIPLE" ? "checkbox" : "radio"} checked={answer.selected.includes(index + 1)} onChange={() => changeAnswer(answer, index + 1)} />{option}</label>)}</fieldset>
                  : <p>Выбрано:<AnswerLines values={answerLabels(question, answer.selected)} /></p>}
                <p>Правильно:<AnswerLines values={answerLabels(question, answer.correct)} /></p>
              </li>
            );
          })}
        </ul>
      )}
      <p className="actions"><button className="primary" type="button" onClick={onExit}>Вернуться в кабинет</button></p>
    </section>
  );
}

function AppealForm({ attempt, onExit }) {
  const [form, setForm] = useState({ questionIndexes: [], exampleDescription: "", interpretation: "", legalReference: "" });
  const [review, setReview] = useState(null);
  const [attachment, setAttachment] = useState(null);
  const [error, setError] = useState("");
  const [busy, setBusy] = useState(false);
  useEffect(() => { api(`/api/attempts/${attempt.id}/review`).then(setReview).catch((cause) => setError(cause.message)); }, [attempt.id]);
  function change(event) { setForm({ ...form, [event.target.name]: event.target.value }); }
  async function submit(event) {
    event.preventDefault(); setBusy(true); setError("");
    try {
      if (!attachment) throw new Error("Приложите скриншот или PDF");
      const base64 = await fileBase64(attachment);
      await api(`/api/my/attempts/${attempt.id}/appeal`, { method: "POST", body: JSON.stringify({ ...form, attachmentName: attachment.name, attachmentType: attachment.type, attachmentBase64: base64 }) });
      onExit();
    } catch (cause) { setError(cause.message); } finally { setBusy(false); }
  }
  return <section className="panel test-panel"><p className="eyebrow">Апелляция</p><h1>{attempt.testTitle}</h1>
    <form className="appeal-form" onSubmit={submit}>
      <fieldset className="appeal-questions"><legend>Выберите неверные ответы для апелляции</legend>{review?.answers.filter((answer) => !answer.correctAnswer).map((answer) => <label key={answer.index}><input type="checkbox" checked={form.questionIndexes.includes(answer.index)} onChange={() => setForm({ ...form, questionIndexes: form.questionIndexes.includes(answer.index) ? form.questionIndexes.filter((index) => index !== answer.index) : [...form.questionIndexes, answer.index] })} /><span><b>Вопрос {answer.index + 1}.</b> {answer.text}<small>Выбрано: {formatAnswerSummary(review.questions[answer.index], answer.selected)}</small></span></label>)}</fieldset>
      <label>Описание выполненного примера<textarea name="exampleDescription" value={form.exampleDescription} onChange={change} required /></label>
      <label>Ваша интерпретация результата<textarea name="interpretation" value={form.interpretation} onChange={change} required /></label>
      <label>Ссылка на нормативный документ — при необходимости<input type="text" name="legalReference" value={form.legalReference} onChange={change} /></label>
      <label>Скриншот или PDF до 10 МБ<input type="file" accept="image/png,image/jpeg,application/pdf" onChange={(event) => setAttachment(event.target.files[0])} required /></label>
      {error && <p className="error">{error}</p>}<div className="actions"><button type="button" className="secondary" onClick={onExit}>Отмена</button><button className="primary" disabled={busy}>Отправить апелляцию</button></div>
    </form></section>;
}

function fileBase64(file) {
  if (file.size > 10 * 1024 * 1024) return Promise.reject(new Error("Размер файла превышает 10 МБ"));
  return new Promise((resolve, reject) => { const reader = new FileReader(); reader.onload = () => resolve(String(reader.result).split(",")[1]); reader.onerror = reject; reader.readAsDataURL(file); });
}

function answerLabels(question, numbers) {
  return numbers.length ? numbers.map((number) => question.options[number - 1]) : "нет ответа";
}

function AnswerLines({ values }) {
  return Array.isArray(values) ? values.map((value) => <span className="answer-line" key={value}>{value}</span>) : <span className="answer-line">{values}</span>;
}

function formatAnswerSummary(question, numbers) {
  const values = answerLabels(question, numbers);
  return Array.isArray(values) ? values.join("; ") : values;
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

function toMoscowInput(date) {
  const parts = new Intl.DateTimeFormat("sv-SE", {
    timeZone: "Europe/Moscow",
    year: "numeric", month: "2-digit", day: "2-digit",
    hour: "2-digit", minute: "2-digit", hour12: false,
  }).formatToParts(date);
  const value = Object.fromEntries(parts.map((part) => [part.type, part.value]));
  return `${value.year}-${value.month}-${value.day}T${value.hour}:${value.minute}`;
}

function toMoscowIso(value) {
  return new Date(`${value}:00+03:00`).toISOString();
}
