export type SiteId = 'querydesk' | 'terradesk'

export interface NavGroup {
  title: string
  links: Array<{ title: string; href: string }>
}

export interface GuideCard {
  href: string
  name: string
  description: string
}

export interface ResourceCard {
  href: string
  name: string
  description: string
  icon: 'user' | 'chat' | 'envelope' | 'users'
  pattern: { y: number; squares: Array<[x: number, y: number]> }
}

export interface Site {
  id: SiteId
  /** Product name as it appears in prose and titles. */
  name: string
  /** Hostnames that serve this site. */
  hosts: Array<string>
  description: string
  navigation: Array<NavGroup>
  guides: { intro: string; cards: Array<GuideCard> }
  resources: { intro: string; cards: Array<ResourceCard> }
}

export const sites: Record<SiteId, Site> = {
  querydesk: {
    id: 'querydesk',
    name: 'QueryDesk',
    hosts: ['docs.querydesk.com'],
    description:
      'Find useful information on how to get the most out of QueryDesk.',
    navigation: [
      {
        title: 'Guides',
        links: [
          { title: 'Introduction', href: '/' },
          { title: 'Getting Started', href: '/guides/getting-started' },
          { title: 'Sample Database', href: '/guides/sample-database' },
          { title: 'Authentication', href: '/guides/authentication' },
          { title: 'Terraform', href: '/guides/terraform' },
          { title: 'GitHub Actions', href: '/guides/github-actions' },
          { title: 'Seat Automation', href: '/guides/seat-automation' },
          { title: 'Workflows', href: '/guides/workflows' },
          { title: 'Data Protection', href: '/guides/data-protection' },
          { title: 'Tunnels', href: '/guides/tunnels' },
          { title: 'Security', href: '/guides/security' },
        ],
      },
      {
        title: 'AI',
        links: [
          { title: 'MCP Server', href: '/ai/mcp-server' },
          { title: 'MCP Tools', href: '/ai/mcp-tools' },
          { title: 'AI Governance', href: '/ai/governance' },
        ],
      },
      {
        title: 'Resources',
        links: [
          { title: 'Dashboards', href: '/resources/dashboards' },
          { title: 'Databases', href: '/resources/databases' },
          { title: 'Workflows', href: '/resources/workflows' },
        ],
      },
    ],
    guides: {
      intro:
        'There are many ways to manage your QueryDesk resources including Terraform, GitHub Actions, and APIs. This documentation will help you get started.',
      cards: [
        {
          href: '/guides/authentication',
          name: 'Authentication',
          description: 'Learn how to authenticate your API requests.',
        },
        {
          href: '/guides/terraform',
          name: 'Terraform',
          description:
            'Learn how to manage your QueryDesk resources with Terraform.',
        },
        {
          href: '/guides/github-actions',
          name: 'GitHub Actions',
          description:
            'Learn how to manage your QueryDesk resources with GitHub Actions.',
        },
        {
          href: '/guides/seat-automation',
          name: 'Seat Automation',
          description:
            'Learn how to add or remove seats on your license from an automated flow.',
        },
        {
          href: '/guides/workflows',
          name: 'Workflows',
          description:
            'Learn how to automate your processes with QueryDesk workflows.',
        },
        {
          href: '/guides/data-protection',
          name: 'Data Protection',
          description:
            'Learn how QueryDesk implements data protection to simplify meeting compliance requirements.',
        },
        {
          href: '/guides/tunnels',
          name: 'Tunnels',
          description:
            'Reach databases and clusters in a private network without opening anything inbound.',
        },
        {
          href: '/guides/security',
          name: 'Security',
          description:
            'Understand the architecture that keeps your data inside your own infrastructure.',
        },
      ],
    },
    resources: {
      intro:
        'Explore the resources you can manage through the API and Terraform.',
      cards: [
        {
          href: '/resources/databases',
          name: 'Databases',
          description:
            'Learn about the database model and how to create, retrieve, update, delete, and list databases.',
          icon: 'user',
          pattern: {
            y: 16,
            squares: [
              [0, 1],
              [1, 3],
            ],
          },
        },
        {
          href: '/resources/workflows',
          name: 'Workflows',
          description:
            'Learn about the conversation model and how to create, retrieve, update, delete, and list conversations.',
          icon: 'chat',
          pattern: {
            y: -6,
            squares: [
              [-1, 2],
              [1, 3],
            ],
          },
        },
        {
          href: '/resources/dashboards',
          name: 'Dashboards',
          description:
            'Learn about the message model and how to create, retrieve, update, delete, and list messages.',
          icon: 'envelope',
          pattern: {
            y: 32,
            squares: [
              [0, 2],
              [1, 4],
            ],
          },
        },
      ],
    },
  },
  terradesk: {
    id: 'terradesk',
    name: 'TerraDesk',
    hosts: ['docs.terradesk.io'],
    description:
      'Find useful information on how to get the most out of TerraDesk.',
    navigation: [
      {
        title: 'Guides',
        links: [
          { title: 'Introduction', href: '/' },
          { title: 'Getting Started', href: '/guides/getting-started' },
          { title: 'Workspaces', href: '/guides/workspaces' },
          { title: 'Plans and Applies', href: '/guides/plans-and-applies' },
          { title: 'Approvals', href: '/guides/approvals' },
          { title: 'Drift Detection', href: '/guides/drift-detection' },
          { title: 'Authentication', href: '/guides/authentication' },
          { title: 'Terraform', href: '/guides/terraform' },
          { title: 'Security', href: '/guides/security' },
        ],
      },
      {
        title: 'Resources',
        links: [{ title: 'Workspaces', href: '/resources/workspaces' }],
      },
    ],
    guides: {
      intro:
        'TerraDesk runs your Terraform and OpenTofu plans and applies inside your own cluster, behind approval gates you control. These guides cover setting it up and running it day to day.',
      cards: [
        {
          href: '/guides/getting-started',
          name: 'Getting Started',
          description:
            'Connect a repository, create your first workspace, and run a plan.',
        },
        {
          href: '/guides/workspaces',
          name: 'Workspaces',
          description:
            'Configure the repository, image, containers, variables, and secrets a workspace runs with.',
        },
        {
          href: '/guides/approvals',
          name: 'Approvals',
          description:
            'Raise the bar on an apply with baseline approvals, reservations, and resource policies.',
        },
        {
          href: '/guides/drift-detection',
          name: 'Drift Detection',
          description:
            'Find out on a schedule what changed outside of Terraform, and reconcile it safely.',
        },
        {
          href: '/guides/security',
          name: 'Security',
          description:
            'Understand the architecture that keeps your state, credentials, and cloud access inside your infrastructure.',
        },
      ],
    },
    resources: {
      intro:
        'Explore the resources you can manage through the API and Terraform.',
      cards: [
        {
          href: '/resources/workspaces',
          name: 'Workspaces',
          description:
            'Learn about the workspace model and how to create, retrieve, update, and delete workspaces.',
          icon: 'user',
          pattern: {
            y: 16,
            squares: [
              [0, 1],
              [1, 3],
            ],
          },
        },
      ],
    },
  },
}

export const siteIds = Object.keys(sites) as Array<SiteId>

export const defaultSiteId: SiteId = 'querydesk'

/** Resolve a request's `Host` header to the site it should serve. */
export function siteIdForHost(host: string | null | undefined): SiteId {
  let hostname = (host ?? '').split(':')[0].toLowerCase()

  for (let site of Object.values(sites)) {
    if (site.hosts.includes(hostname)) {
      return site.id
    }
    // `terradesk.localhost` and the like, so both sites are reachable in dev.
    if (hostname.startsWith(`${site.id}.`) || hostname === site.id) {
      return site.id
    }
  }

  return defaultSiteId
}

/** Strip the internal site prefix middleware adds, leaving the public path. */
export function stripSitePrefix(pathname: string): string {
  for (let id of siteIds) {
    if (pathname === `/${id}`) return '/'
    if (pathname.startsWith(`/${id}/`)) return pathname.slice(id.length + 1)
  }
  return pathname
}
