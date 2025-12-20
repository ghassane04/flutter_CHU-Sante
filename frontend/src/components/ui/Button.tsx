import React from 'react';
import { Loader2 } from 'lucide-react';

type ButtonVariant = 'primary' | 'secondary' | 'ghost' | 'danger';
type ButtonSize = 'sm' | 'md' | 'lg';

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: ButtonVariant;
  size?: ButtonSize;
  loading?: boolean;
  fullWidth?: boolean;
  children: React.ReactNode;
}

export function Button({
  variant = 'primary',
  size = 'md',
  loading = false,
  fullWidth = false,
  children,
  className = '',
  disabled,
  ...props
}: ButtonProps) {
  const baseClasses = 'btn inline-flex items-center justify-center font-medium transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-offset-2';
  
  const variantClasses = {
    primary: 'bg-[#0B6FB0] text-white hover:bg-[#095a8f] focus:ring-[#0B6FB0] active:bg-[#074166] disabled:opacity-50',
    secondary: 'bg-[#17A2A6] text-white hover:bg-[#138e92] focus:ring-[#17A2A6] active:bg-[#0f7276] disabled:opacity-50',
    ghost: 'bg-transparent text-[#0B6FB0] hover:bg-gray-100 focus:ring-[#0B6FB0] active:bg-gray-200 disabled:opacity-50',
    danger: 'bg-[#F56565] text-white hover:bg-[#e53e3e] focus:ring-[#F56565] active:bg-[#c53030] disabled:opacity-50',
  };
  
  const sizeClasses = {
    sm: 'h-10 px-4 text-sm rounded-md',
    md: 'h-11 px-6 text-base rounded-lg md:h-10',
    lg: 'h-12 px-8 text-base rounded-lg',
  };
  
  const widthClass = fullWidth ? 'w-full' : '';
  
  return (
    <button
      className={`${baseClasses} ${variantClasses[variant]} ${sizeClasses[size]} ${widthClass} ${className}`}
      disabled={disabled || loading}
      {...props}
    >
      {loading && <Loader2 className="w-4 h-4 mr-2 animate-spin" />}
      {children}
    </button>
  );
}
