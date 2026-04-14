import type { ButtonHTMLAttributes } from 'react'
import { Link, type LinkProps } from 'react-router-dom'

type Variant = 'primary' | 'secondary' | 'ghost'

const baseClass =
  'inline-flex items-center justify-center gap-2 rounded-lg px-4 py-2.5 text-sm font-semibold transition focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 disabled:opacity-50'

const variantClass: Record<Variant, string> = {
  primary:
    'bg-flexline-green text-white hover:bg-flexline-green-hover focus-visible:outline-flexline-green',
  secondary:
    'border border-flexline-green text-flexline-green bg-white hover:bg-emerald-50 focus-visible:outline-flexline-green',
  ghost: 'text-flexline-navy hover:bg-flexline-sidebar',
}

type Props = ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: Variant
}

export function Button({
  variant = 'primary',
  className = '',
  children,
  ...rest
}: Props) {
  return (
    <button
      className={`${baseClass} ${variantClass[variant]} ${className}`}
      {...rest}
    >
      {children}
    </button>
  )
}

export function LinkButton({
  variant = 'primary',
  className = '',
  children,
  ...rest
}: LinkProps & { variant?: Variant }) {
  return (
    <Link
      className={`${baseClass} ${variantClass[variant]} ${className}`}
      {...rest}
    >
      {children}
    </Link>
  )
}
