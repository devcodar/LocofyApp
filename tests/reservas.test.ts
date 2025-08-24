import { describe, it, expect } from 'vitest';
import { hasOverlap } from '../lib/validators';

describe('hasOverlap', () => {
  it('detects overlapping reservations', () => {
    const existing = [{ inicio: new Date('2023-01-01'), fim: new Date('2023-01-02') }];
    expect(hasOverlap(new Date('2023-01-01T12:00:00Z'), new Date('2023-01-03'), existing)).toBe(true);
  });
  it('allows non overlapping reservations', () => {
    const existing = [{ inicio: new Date('2023-01-01'), fim: new Date('2023-01-02') }];
    expect(hasOverlap(new Date('2023-01-02T12:00:00Z'), new Date('2023-01-03'), existing)).toBe(false);
  });
});
