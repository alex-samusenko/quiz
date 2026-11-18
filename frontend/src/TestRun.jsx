import { useEffect, useRef, useState } from "react";
import { api } from "./api";

const DIFFICULTY = {
  EASY: "Лёгкий",
  MEDIUM: "Средний",
  HARD: "Сложный",
};

const CHOICE = {
  SINGLE: "один вариант",
  MULTIPLE: "несколько вариантов",
};

export default function TestRun({ session, onExit }) {
  const [index, setIndex] = useState(0);
  const [selections, setSelections] = useState(() => (
    session.questions.map((_, questionIndex) => session.selected?.[questionIndex] ?? [])
  ));
  const [result, setResult] = useState(null);
  const [remaining, setRemaining] = useState(session.remainingSeconds);
  const [error, setError] = useState("");
  const [busy, setBusy] = useState(false);
  const [confirming, setConfirming] = useState(false);
  const finished = useRef(false);
  const stateRef = useRef({});
  const saveQueue = useRef(Promise.resolve());
  stateRef.current = { index, selections, session, remaining };

  useEffect(() => {
    if (result) {
      return undefined;
    }
    const endsAt = Date.now() + session.remainingSeconds * 1000;
    const tick = () => {
      const left = Math.max(0, Math.round((endsAt - Date.now()) / 1000));
      setRemaining(left);
      if (left === 0) {
        finish(stateRef.current);
      }
    };
    tick();
    const timerId = setInterval(tick, 1000);
    return () => clearInterval(timerId);
  }, [session, result]);

  function toggle(optionNumber) {
    const question = session.questions[index];
    const current = stateRef.current.selections[index] ?? [];
    const nextSelected = question.choiceType === "SINGLE"
      ? [optionNumber]
      : current.includes(optionNumber)
        ? current.filter((value) => value !== optionNumber)
        : [...current, optionNumber];
    const nextSelections = stateRef.current.selections.map((values, questionIndex) => (
      questionIndex === index ? nextSelected : values
    ));
    stateRef.current = { ...stateRef.current, selections: nextSelections };
    setSelections(nextSelections);
    setError("");
    saveQueue.current = saveQueue.current
      .then(() => persistAnswer(session.id, index, nextSelected))
      .catch((cause) => setError(cause.message));
  }

  async function persistAnswer(attemptId, questionIndex, selected) {
    await api(`/api/attempts/${attemptId}/answers`, {
      method: "PUT",
      body: JSON.stringify({ questionIndex, selected }),
    });
  }

  async function move(nextIndex) {
    setBusy(true);
    setError("");
    try {
      await saveQueue.current;
      setIndex(nextIndex);
    } catch (cause) {
      setError(cause.message);
    } finally {
      setBusy(false);
    }
  }

  async function finish(snapshot) {
    if (finished.current) {
      return;
    }
    finished.current = true;
    const current = snapshot ?? stateRef.current;
    setBusy(true);
    setError("");
    try {
      await saveQueue.current;
      setResult(await api(`/api/attempts/${current.session.id}/finish`, { method: "POST" }));
    } catch (cause) {
      finished.current = false;
      setError(cause.message);
    } finally {
      setBusy(false);
    }
  }

  function requestFinish() {
    setConfirming(true);
  }

  if (result) {
    return <Result session={session} result={result} onExit={onExit} />;
  }

  return (
    <QuestionStep
      session={session}
      index={index}
      selected={selections[index] ?? []}
      selections={selections}
      remaining={remaining}
      error={error}
      busy={busy}
      confirming={confirming}
      onToggle={toggle}
      onBack={() => move(index - 1)}
      onNext={() => (index === session.questions.length - 1 ? requestFinish() : move(index + 1))}
      onNavigate={move}
      onRequestFinish={requestFinish}
      onCancelFinish={() => setConfirming(false)}
      onConfirmFinish={() => {
        setConfirming(false);
        finish();
      }}
    />
  );
}

function QuestionStep({
  session, index, selected, selections, remaining, error, busy, confirming,
  onToggle, onBack, onNext, onNavigate, onRequestFinish, onCancelFinish, onConfirmFinish,
}) {
  const question = session.questions[index];
  const inputType = question.choiceType === "SINGLE" ? "radio" : "checkbox";
  const progress = ((index + 1) / session.questions.length) * 100;
  const answeredCount = session.questions.reduce(
    (count, _, questionIndex) => count + ((selections[questionIndex]?.length ?? 0) > 0 ? 1 : 0), 0,
  );
  const unansweredCount = session.questions.length - answeredCount;
  return (
    <section className="panel test-panel">
      <div className="exam-header">
        <div>
          <p className="eyebrow">{session.testTitle}</p>
          <span className="exam-count">Вопрос {index + 1} из {session.questions.length}</span>
        </div>
        <span className={`timer ${remaining <= 60 ? "urgent" : ""}`}>{formatTime(remaining)}</span>
      </div>
      <div className="progress-track" aria-hidden="true">
        <div className="progress-bar" style={{ width: `${progress}%` }} />
      </div>
      <div className="question-navigation">
        <div className="question-nav-summary">
          <strong>Отвечено {answeredCount} из {session.questions.length}</strong>
          <span>{unansweredCount > 0 ? `Осталось: ${unansweredCount}` : "Все вопросы заполнены"}</span>
        </div>
        <div className="question-numbers" aria-label="Навигация по вопросам">
          {session.questions.map((_, questionIndex) => {
            const answered = (selections[questionIndex]?.length ?? 0) > 0;
            return (
              <button
                className={`question-number ${questionIndex === index ? "current" : ""} ${answered ? "answered" : ""}`}
                type="button"
                key={questionIndex}
                onClick={() => onNavigate(questionIndex)}
                disabled={busy || questionIndex === index}
                aria-label={`Вопрос ${questionIndex + 1}${answered ? ", отвечен" : ", без ответа"}`}
              >
                {questionIndex + 1}
              </button>
            );
          })}
        </div>
      </div>
      <div className="meta">
        <span>{DIFFICULTY[question.difficulty]} · {question.weight}%</span>
        <span>{CHOICE[question.choiceType]}</span>
      </div>
      <h1 className="question-title">{question.text}</h1>
      <div className="options">
        {question.options.map((option, optionIndex) => {
          const number = optionIndex + 1;
          return (
            <label className="option" key={`${index}-${number}`}>
              <input
                type={inputType}
                name={`question-${index}`}
                checked={selected.includes(number)}
                onChange={() => onToggle(number)}
              />
              <span>{option}</span>
            </label>
          );
        })}
      </div>
      {error && <p className="error">{error}</p>}
      <div className="actions">
        <div className="step-actions">
          <button className="secondary" type="button" onClick={onBack} disabled={busy || index === 0}>Назад</button>
          <button className="primary" type="button" onClick={onNext} disabled={busy}>
            {index === session.questions.length - 1 ? "Проверить и завершить" : "Далее"}
          </button>
        </div>
        {index !== session.questions.length - 1 && (
          <button className="finish-link" type="button" onClick={onRequestFinish} disabled={busy}>Завершить тест</button>
        )}
      </div>
      {confirming && (
        <div className="modal-backdrop" role="presentation">
          <section className="confirm-dialog" role="dialog" aria-modal="true" aria-labelledby="finish-title">
            <p className="eyebrow">Завершение аттестации</p>
            <h2 id="finish-title">Отправить ответы?</h2>
            <p>После завершения изменить ответы будет нельзя.</p>
            <div className="finish-summary">
              <span><strong>{answeredCount}</strong> отвечено</span>
              <span className={unansweredCount > 0 ? "warning" : "complete"}><strong>{unansweredCount}</strong> пропущено</span>
            </div>
            {unansweredCount > 0 && <p className="confirm-warning">Пропущенные вопросы будут засчитаны как неправильные.</p>}
            <div className="dialog-actions">
              <button className="secondary" type="button" onClick={onCancelFinish} disabled={busy}>Вернуться к вопросам</button>
              <button className="primary" type="button" onClick={onConfirmFinish} disabled={busy}>Завершить тест</button>
            </div>
          </section>
        </div>
      )}
    </section>
  );
}

function Result({ session, result, onExit }) {
  return (
    <section className="panel test-panel">
      <p className="eyebrow">{session.testTitle}</p>
      <h1 className={result.passed ? "passed" : "failed"}>
        {result.passed ? "Аттестация сдана" : "Аттестация не сдана"}
      </h1>
      <p className="result-score">{result.scorePercent} из 100</p>
      <p className="hint">
        Правильных ответов: {result.rightAnswersCount} из {result.questionsCount}.
        Проходной балл: {session.passingScore}.
      </p>
      {result.mistakes.length > 0 && (
        <ul className="mistakes">
          {result.mistakes.map((mistake) => {
            const question = session.questions[mistake.index];
            return (
              <li key={mistake.index}>
                <strong>{mistake.text}</strong>
                <p>Ваш выбор: {labels(question, mistake.selected)}</p>
                <p>Правильно: {labels(question, mistake.correct)}</p>
              </li>
            );
          })}
        </ul>
      )}
      <p className="actions">
        <button className="primary" type="button" onClick={onExit}>В кабинет</button>
      </p>
    </section>
  );
}

function labels(question, numbers) {
  if (!numbers.length) {
    return "нет ответа";
  }
  return numbers.map((number) => question.options[number - 1]).join("; ");
}

function formatTime(totalSeconds) {
  if (totalSeconds == null) {
    return "";
  }
  const minutes = Math.floor(totalSeconds / 60);
  const seconds = totalSeconds % 60;
  return `${String(minutes).padStart(2, "0")}:${String(seconds).padStart(2, "0")}`;
}
