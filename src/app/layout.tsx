import { type Metadata } from 'next'
import { headers } from 'next/headers'
import glob from 'fast-glob'

import { Providers } from '@/app/providers'
import { Layout } from '@/components/Layout'
import { type Section } from '@/components/SectionProvider'
import { SiteProvider } from '@/components/SiteProvider'
import { siteIdForHost, sites, stripSitePrefix } from '@/lib/sites'

import '@/styles/tailwind.css'

function currentSite() {
  return sites[siteIdForHost(headers().get('host'))]
}

export function generateMetadata(): Metadata {
  let site = currentSite()

  return {
    title: {
      template: `%s - ${site.name} Documentation`,
      default: `${site.name} Documentation`,
    },
    description: site.description,
  }
}

export default async function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  let site = currentSite()

  // Only this site's pages, so a section lookup can never land on the other
  // product's page of the same name.
  let pages = await glob(`${site.id}/**/*.mdx`, { cwd: 'src/app' })
  let allSectionsEntries = (await Promise.all(
    pages.map(async (filename) => [
      stripSitePrefix('/' + filename.replace(/(^|\/)page\.mdx$/, '')),
      (await import(`./${filename}`)).sections,
    ]),
  )) as Array<[string, Array<Section>]>
  let allSections = Object.fromEntries(allSectionsEntries)

  return (
    <html lang="en" className="h-full" suppressHydrationWarning>
      <body className="flex min-h-full bg-white antialiased dark:bg-zinc-900">
        <Providers>
          <SiteProvider site={site}>
            <div className="w-full">
              <Layout allSections={allSections}>{children}</Layout>
            </div>
          </SiteProvider>
        </Providers>
      </body>
    </html>
  )
}
