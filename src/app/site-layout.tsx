import { type Metadata } from 'next'
import glob from 'fast-glob'

import { Layout } from '@/components/Layout'
import { type Section } from '@/components/SectionProvider'
import { SiteProvider } from '@/components/SiteProvider'
import { type SiteId, sites, stripSitePrefix } from '@/lib/sites'

export function siteMetadata(id: SiteId): Metadata {
  let site = sites[id]

  return {
    title: {
      template: `%s - ${site.name} Documentation`,
      default: `${site.name} Documentation`,
    },
    description: site.description,
  }
}

/**
 * The chrome every product's docs share. Kept out of the root layout so no
 * request-time API is needed to know which product this is: the route segment
 * already says, which keeps every page statically rendered.
 */
export async function SiteLayout({
  id,
  children,
}: {
  id: SiteId
  children: React.ReactNode
}) {
  // Only this site's pages, so a section lookup can never land on the other
  // product's page of the same name.
  let pages = await glob(`${id}/**/*.mdx`, { cwd: 'src/app' })
  let allSectionsEntries = (await Promise.all(
    pages.map(async (filename) => [
      stripSitePrefix('/' + filename.replace(/(^|\/)page\.mdx$/, '')),
      (await import(`./${filename}`)).sections,
    ]),
  )) as Array<[string, Array<Section>]>
  let allSections = Object.fromEntries(allSectionsEntries)

  return (
    <SiteProvider site={sites[id]}>
      <div className="w-full">
        <Layout allSections={allSections}>{children}</Layout>
      </div>
    </SiteProvider>
  )
}
