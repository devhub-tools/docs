import { SiteLayout, siteMetadata } from '@/app/site-layout'

export const metadata = siteMetadata('querydesk')

export default function ProductLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return <SiteLayout id="querydesk">{children}</SiteLayout>
}
