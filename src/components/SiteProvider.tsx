'use client'

import { createContext, useContext } from 'react'
import { usePathname } from 'next/navigation'

import { type Site, stripSitePrefix } from '@/lib/sites'

const SiteContext = createContext<Site | null>(null)

export function SiteProvider({
  site,
  children,
}: {
  site: Site
  children: React.ReactNode
}) {
  return <SiteContext.Provider value={site}>{children}</SiteContext.Provider>
}

export function useSite() {
  let site = useContext(SiteContext)
  if (!site) {
    throw new Error('useSite must be used inside a SiteProvider')
  }
  return site
}

// Every link is written as a public path. Whether usePathname reports the
// browser's path or the one middleware rewrote to depends on how the render was
// reached, so normalize rather than depend on it.
export function usePagePath() {
  return stripSitePrefix(usePathname())
}
