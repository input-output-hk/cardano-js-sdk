import { Days, Hours, Milliseconds, Minutes, Seconds, TimeSpan } from '../../src/util/index.js';

const oneAndAHalfDay = Milliseconds(129_600_000);
const twentyMinutesAndTenSeconds = Milliseconds(1_210_000);
const oneMinuteAndTenMilliseconds = Milliseconds(60_010);

describe('Cardano.util.time', () => {
  describe('units', () => {
    it('can convert from milliseconds to seconds', () => {
      const milliseconds = Milliseconds(1000);
      expect(Milliseconds.toSeconds(milliseconds)).toBe(1);
    });
    it('can convert from seconds to milliseconds', () => {
      const seconds = Seconds(1);
      expect(Seconds.toMilliseconds(seconds)).toBe(1000);
    });
    it('can convert from seconds to minutes', () => {
      const seconds = Seconds(120);
      expect(Seconds.toMinutes(seconds)).toBe(2);
    });
    it('can convert from minutes to seconds', () => {
      const minutes = Minutes(2);
      expect(Minutes.toSeconds(minutes)).toBe(120);
    });
    it('can convert from minutes to hours', () => {
      const minutes = Minutes(60);
      expect(Minutes.toHours(minutes)).toBe(1);
    });
    it('can convert from hours to minutes', () => {
      const hours = Hours(3);
      expect(Hours.toMinutes(hours)).toBe(180);
    });
    it('can convert from hours to days', () => {
      const hours = Hours(48);
      expect(Hours.toDays(hours)).toBe(2);
    });
    it('can convert from days to hours', () => {
      const days = Days(2);
      expect(Days.toHours(days)).toBe(48);
    });
  });
  describe('TimeSpan', () => {
    it('can get the right number of total days', () => {
      const span = new TimeSpan(oneAndAHalfDay);
      expect(span.getTotalDays()).toBe(1.5);
    });
    it('can get the right number of total hours', () => {
      const span = new TimeSpan(oneAndAHalfDay);
      expect(span.getTotalHours()).toBe(36);
    });
    it('can get the right number of total minutes', () => {
      const span = new TimeSpan(oneAndAHalfDay);
      expect(span.getTotalMinutes()).toBe(2160);
    });
    it('can get the right number of total seconds', () => {
      const span = new TimeSpan(oneAndAHalfDay);
      expect(span.getTotalSeconds()).toBe(129_600);
    });
    it('can get the right number of total milliseconds', () => {
      const span = new TimeSpan(oneAndAHalfDay);
      expect(span.getTotalMilliseconds()).toBe(129_600_000);
    });
    it('can get the days component of the elapsed time', () => {
      const span = new TimeSpan(oneAndAHalfDay);
      expect(span.getDays()).toBe(1);
    });
    it('can get the hours component of the elapsed time', () => {
      const span = new TimeSpan(oneAndAHalfDay);
      expect(span.getHours()).toBe(12);
    });
    it('can get the minutes component of the elapsed time', () => {
      const span = new TimeSpan(twentyMinutesAndTenSeconds);
      expect(span.getMinutes()).toBe(20);
    });
    it('can get the seconds component of the elapsed time', () => {
      const span = new TimeSpan(twentyMinutesAndTenSeconds);
      expect(span.getSeconds()).toBe(10);
    });
    it('can get the milliseconds component of the elapsed time', () => {
      const span = new TimeSpan(oneMinuteAndTenMilliseconds);
      expect(span.getMilliseconds()).toBe(10);
    });
    it('can convert the time value to an ISO-8601 duration string', () => {
      const span = TimeSpan.fromSeconds(Seconds(102_751));
      expect(span.toString()).toBe('P1DT4H32M31S');
    });
    it('can be created from seconds', () => {
      const span = TimeSpan.fromSeconds(Seconds(120));
      expect(span.getTotalMilliseconds()).toBe(120_000);
    });
    it('can be created from minutes', () => {
      const span = TimeSpan.fromMinutes(Minutes(10));
      expect(span.getTotalMilliseconds()).toBe(600_000);
    });
    it('can be created from hours', () => {
      const span = TimeSpan.fromHours(Hours(2));
      expect(span.getTotalMilliseconds()).toBe(7_200_000);
    });
  });
});
