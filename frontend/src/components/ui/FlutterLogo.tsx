import React from 'react';

interface FlutterLogoProps {
  className?: string;
  size?: number;
}

export function FlutterLogo({ className = '', size = 32 }: FlutterLogoProps) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 256 317"
      className={className}
      xmlns="http://www.w3.org/2000/svg"
      preserveAspectRatio="xMidYMid"
    >
      <defs>
        <linearGradient id="flutterGradient1" x1="3.952%" y1="26.993%" x2="75.897%" y2="52.919%">
          <stop offset="0%" stopColor="#000000" />
          <stop offset="100%" stopColor="#000000" stopOpacity="0" />
        </linearGradient>
      </defs>
      <path
        d="M157.666 0L0 157.666l48.8 48.8L254.134 0z"
        fill="#42A5F5"
        fillOpacity=".851"
      />
      <path
        d="M156.567 145.397L72.1 229.8l48.9 48.9.1-.1 83.4-83.4-48.8-49.9z"
        fill="#0D47A1"
      />
      <path
        d="M121.1 229.8l-48.9-48.8 48.9-48.9 48.9 48.9z"
        fill="#42A5F5"
      />
      <path
        d="M121.1 229.8l-48.9-48.8 48.9-48.9 48.9 48.9z"
        fill="url(#flutterGradient1)"
        fillOpacity=".25"
      />
      <path
        d="M157.666 145.397L72.1 229.8l48.9 48.9.1-.1 83.4-83.4-48.8-49.9z"
        fill="#1976D2"
      />
    </svg>
  );
}
