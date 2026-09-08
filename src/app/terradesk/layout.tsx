import { SiteLayout, siteMetadata } from '@/app/site-layout'

export const metadata = siteMetadata('terradesk')

export default function ProductLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return <SiteLayout id="terradesk">{children}</SiteLayout>
}
