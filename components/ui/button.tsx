'use client';
import * as React from 'react';
import { cn } from '@/lib/utils';

type ButtonProps = React.ButtonHTMLAttributes<HTMLButtonElement>;

export const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, ...props }, ref) => (
    <button
      ref={ref}
      className={cn('px-4 py-2 rounded bg-blue-600 text-white', className)}
      {...props}
    />
  )
);
Button.displayName = 'Button';
