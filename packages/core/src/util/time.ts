import type { OpaqueNumber } from '@cardano-sdk/util';

/** Milliseconds time unit. */
export type Milliseconds = OpaqueNumber<'Milliseconds'>;
export const Milliseconds = (value: number): Milliseconds => value as unknown as Milliseconds;

/** Seconds time unit. */
export type Seconds = OpaqueNumber<'Seconds'>;
export const Seconds = (value: number): Seconds => value as unknown as Seconds;

/** Minutes time unit. */
export type Minutes = OpaqueNumber<'Minutes'>;
export const Minutes = (value: number): Minutes => value as unknown as Minutes;

/** Hours time unit. */
export type Hours = OpaqueNumber<'Hours'>;
export const Hours = (value: number): Hours => value as unknown as Hours;

/** days time unit. */
export type Days = OpaqueNumber<'Days'>;
export const Days = (value: number): Days => value as unknown as Days;

Hours.toDays = (value: Hours): Days => (value / 24) as unknown as Days;
Days.toHours = (value: Days): Hours => (value * 24) as unknown as Hours;

Minutes.toHours = (value: Minutes): Hours => (value / 60) as unknown as Hours;
Hours.toMinutes = (value: Hours): Minutes => (value * 60) as unknown as Minutes;

Seconds.toMinutes = (value: Seconds): Minutes => (value / 60) as unknown as Minutes;
Minutes.toSeconds = (value: Minutes): Seconds => (value * 60) as unknown as Seconds;

Seconds.toMilliseconds = (value: Seconds): Milliseconds => (value * 1000) as unknown as Milliseconds;
Milliseconds.toSeconds = (value: Milliseconds): Seconds => (value / 1000) as unknown as Seconds;

/** Represents a time interval. */
export class TimeSpan {
  private readonly elapsed = Milliseconds(0);

  /**
   * Initializes a new instance of the TimeSpan class.
   *
   * @param elapsed The time interval in milliseconds.
   */
  constructor(elapsed: Milliseconds) {
    this.elapsed = elapsed;
  }

  /**
   * Creates a time span from milliseconds.
   *
   * @param milliseconds The number of milliseconds.
   * @returns The time span.
   */
  public static fromMilliseconds(milliseconds: Milliseconds): TimeSpan {
    return new TimeSpan(milliseconds);
  }

  /**
   * Creates a time span from seconds.
   *
   * @param seconds The number of seconds.
   * @returns The time span.
   */
  public static fromSeconds(seconds: Seconds): TimeSpan {
    return new TimeSpan(Seconds.toMilliseconds(seconds));
  }

  /**
   * Creates a time span from minutes.
   *
   * @param minutes The number of minutes.
   * @returns The time span.
   */
  public static fromMinutes(minutes: Minutes): TimeSpan {
    return new TimeSpan(Seconds.toMilliseconds(Minutes.toSeconds(minutes)));
  }

  /**
   * Creates a time span from hours.
   *
   * @param hours The number of hours.
   * @returns The time span.
   */
  public static fromHours(hours: Hours): TimeSpan {
    return new TimeSpan(Seconds.toMilliseconds(Minutes.toSeconds(Hours.toMinutes(hours))));
  }

  /**
   * Gets the value of the current TimeSpan expressed in whole and fractional days.
   *
   * @returns The total number of days represented by this instance.
   */
  public getTotalDays(): Days {
    return Hours.toDays(this.getTotalHours());
  }

  /**
   * Gets the value of the current TimeSpan expressed in whole and fractional hours.
   *
   * @returns The total number of hours represented by this instance.
   */
  public getTotalHours(): Hours {
    return Minutes.toHours(this.getTotalMinutes());
  }

  /**
   * Gets the value of the current TimeSpan expressed in whole and fractional minutes.
   *
   * @returns The total number of minutes represented by this instance.
   */
  public getTotalMinutes(): Minutes {
    return Seconds.toMinutes(this.getTotalSeconds());
  }

  /**
   * Gets the value of the current TimeSpan expressed in whole and fractional seconds.
   *
   * @returns The total number of seconds represented by this instance.
   */
  public getTotalSeconds(): Seconds {
    return Milliseconds.toSeconds(this.elapsed);
  }

  /**
   * Gets the value of the current TimeSpan expressed in whole and fractional microseconds.
   *
   * @returns The total number of microseconds represented by this instance.
   */
  public getTotalMilliseconds(): Milliseconds {
    return this.elapsed;
  }

  /**
   * Gets the days component of the time interval represented by the current TimeSpan.
   *
   * @returns The day component of this instance.
   */
  public getDays(): Days {
    return Days(Math.floor(this.getTotalDays()));
  }

  /**
   * Gets the hours component of the time interval represented by the current TimeSpan.
   *
   * @returns The hours component of this instance.
   */
  public getHours(): Hours {
    return Hours(Math.floor(this.getTotalHours() - this.getDays() * 24));
  }

  /**
   * Gets the minutes component of the time interval represented by the current TimeSpan.
   *
   * @returns The minutes component of this instance.
   */
  public getMinutes(): Minutes {
    return Minutes(Math.floor(this.getTotalMinutes() - Math.floor(this.getTotalHours()) * 60));
  }

  /**
   * Gets the seconds component of the time interval represented by the current TimeSpan.
   *
   * @returns The seconds component of this instance.
   */
  public getSeconds(): Seconds {
    return Seconds(Math.floor(this.getTotalSeconds() - Math.floor(this.getTotalMinutes()) * 60));
  }

  /**
   * Gets the milliseconds component of the time interval represented by the current TimeSpan.
   *
   * @returns The millisecond component of this instance.
   */
  public getMilliseconds(): Milliseconds {
    return Milliseconds(this.elapsed - Math.floor(this.getTotalSeconds()) * 1000);
  }

  /**
   * Converts this time span into a string according to ISO-8601 duration standard.
   *
   * @returns The ISO-8601 duration string.
   */
  public toString(): string {
    let result = this.getTotalSeconds() < 0 ? '-P' : 'P';
    let time = '';

    if (this.getHours() !== 0) time += `${Math.abs(this.getHours()).toString()}H`;

    if (this.getMinutes() !== 0) time += `${Math.abs(this.getMinutes()).toString()}M`;

    if (this.getSeconds() !== 0) time += `${Math.abs(this.getSeconds()).toString()}S`;

    if (this.getDays() !== 0 || time === '') result += `${Math.abs(this.getDays()).toString()}D`;

    if (time !== '') result += `T${time}`;

    return result;
  }
}
