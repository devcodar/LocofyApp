export type Role = 'morador' | 'sindico' | 'porteiro' | 'admin';

export function hasRole(role: Role, allowed: Role[]) {
  return allowed.includes(role);
}
