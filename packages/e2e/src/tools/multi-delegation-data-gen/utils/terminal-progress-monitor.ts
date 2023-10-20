import chalk from 'chalk';
import cliSpinners from 'cli-spinners';
import ora from 'ora';

/** The task result. */
export enum TaskResult {
  Success = 0,
  Fail = 1,
  Warning = 2,
  Info = 3,
  None = 4
}

/** Tracks progress of tasks in the terminal. */
export class TerminalProgressMonitor {
  #currentTask: ora.Ora | null = null;

  /**
   * Starts tracking a new task. it will display a spinner while the ask is being tracked.
   *
   * Only one task can be tracked at a time. If you have a current track task, this
   * method will throw.
   *
   * @param message The message of the task.
   */
  startTask(message: string) {
    if (this.#currentTask) throw new Error('Only one task can be tracked at a time');

    this.#currentTask = ora({
      spinner: cliSpinners.dots,
      text: message
    });

    this.#currentTask.start();
  }

  /**
   * Ends the tracking of the current task.
   *
   * @param message The result message to be displayed.
   * @param result The task result.
   */
  endTask(message: string, result: TaskResult) {
    if (!this.#currentTask) return;

    switch (result) {
      case TaskResult.Fail:
        this.#currentTask.fail(chalk.red(message));
        break;
      case TaskResult.Info:
        this.#currentTask.info(message);
        break;
      case TaskResult.Success:
        this.#currentTask.succeed(message);
        break;
      case TaskResult.Warning:
        this.#currentTask.warn(chalk.yellow(message));
        break;
      default:
      case TaskResult.None:
        this.#currentTask.stop();
    }

    this.#currentTask = null;
  }

  /**
   * Gets whether the monitor is currently tracking a task.
   *
   * @returns true if it is tracking a task; otherwise; false.
   */
  isTrackingTask(): boolean {
    return !!this.#currentTask;
  }

  /**
   * Adds a info log entry to the monitor.
   *
   * @param message The result message to be displayed.
   */
  logInfo(message: string) {
    this.log(message, TaskResult.Info);
  }

  /**
   * Adds a warning log entry to the monitor.
   *
   * @param message The result message to be displayed.
   */
  logWarning(message: string) {
    this.log(message, TaskResult.Warning);
  }

  /**
   * Adds a warning log entry to the monitor.
   *
   * @param message The result message to be displayed.
   */
  logFailure(message: string) {
    this.log(message, TaskResult.Fail);
  }

  /**
   * Adds a success log entry to the monitor.
   *
   * @param message The result message to be displayed.
   */
  logSuccess(message: string) {
    this.log(message, TaskResult.Success);
  }

  /**
   * Logs a message into the monitor.
   *
   * @param message The result message to be displayed.
   * @param result The task result.
   */
  private log(message: string, result: TaskResult) {
    if (this.#currentTask) throw new Error('Cant log in the monitor while a task is being tracked');

    const task = ora({
      spinner: cliSpinners.dots,
      text: message
    });

    switch (result) {
      case TaskResult.Fail:
        task.fail(chalk.red(message));
        break;
      case TaskResult.Info:
        task.info(message);
        break;
      case TaskResult.Success:
        task.succeed(message);
        break;
      case TaskResult.Warning:
        task.warn(chalk.yellow(message));
        break;
      default:
      case TaskResult.None:
    }
  }
}
