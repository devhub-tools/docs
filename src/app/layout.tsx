import { type Metadata } from 'next'

import { Providers } from '@/app/providers'

import '@/styles/tailwind.css'

export const metadata: Metadata = {
  title: 'Documentation',
}

// Deliberately free of request-time APIs. Reading the host here would make
// every page dynamic, and the site is already known from the route segment —
// each src/app/<site>/layout.tsx supplies its own site and the shared chrome.
// Only the not-found page renders directly under this layout.
export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en" className="h-full" suppressHydrationWarning>
      <body className="flex min-h-full bg-white antialiased dark:bg-zinc-900">
        <Providers>
          <div className="w-full">{children}</div>
        </Providers>
      </body>
    </html>
  )
}
