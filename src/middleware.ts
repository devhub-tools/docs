import { NextResponse, type NextRequest } from 'next/server'

import { siteIdForHost, siteIds } from '@/lib/sites'

// One deployment serves every product's docs. The route tree is split by
// product (`src/app/<site>/…`) and the request's Host decides which subtree a
// public path resolves to, so the prefix never appears in a URL.
export function middleware(request: NextRequest) {
  let { pathname } = request.nextUrl
  let site = siteIdForHost(request.headers.get('host'))

  // The prefixes are an implementation detail; asking for one directly would
  // expose the other product's docs on this domain.
  if (
    siteIds.some(
      (id) => pathname === `/${id}` || pathname.startsWith(`/${id}/`),
    )
  ) {
    let url = request.nextUrl.clone()
    url.pathname = pathname.replace(/^\/[^/]+/, '') || '/'
    return NextResponse.redirect(url)
  }

  let url = request.nextUrl.clone()
  url.pathname = `/${site}${pathname === '/' ? '' : pathname}`

  return NextResponse.rewrite(url)
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico|robots.txt).*)'],
}
