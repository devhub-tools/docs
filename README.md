# Protocol

Protocol is a [Tailwind UI](https://tailwindui.com) site template built using [Tailwind CSS](https://tailwindcss.com) and [Next.js](https://nextjs.org).

## Getting started

To get started with this template, first install the npm dependencies:

```bash
npm install
```

Next, run the development server:

```bash
npm run dev
```

Finally, open [http://localhost:3000](http://localhost:3000) in your browser to view the website.

## One deployment, several products

This app serves the docs for every Devhub product, and the request's `Host`
decides which one a visitor gets:

| host                 | content              |
| -------------------- | -------------------- |
| `docs.querydesk.io`  | `src/app/querydesk/` |
| `docs.terradesk.io`  | `src/app/terradesk/` |

`src/middleware.ts` rewrites an incoming path onto the right subtree, so the
prefix never appears in a URL — `docs.terradesk.io/guides/security` serves
`src/app/terradesk/guides/security/page.mdx`. Asking for a prefix directly
redirects it away, so one domain can never serve another product's pages.

Everything that differs per product — the product name, navigation, home page
cards, and the hosts it answers to — lives in `src/lib/sites.ts`. Server
components read the host with `headers()`; client components use `useSite()`
from `src/components/SiteProvider.tsx`, and `usePagePath()` instead of
`usePathname()` so links and active state work on the public path.

To add a product: add an entry to `sites.ts` and create `src/app/<id>/`.

### Running both locally

The dev server only ever shows one product at a time, and the hostname you use
decides which. Any hostname starting with a site's id selects it, so with the
server on port 3000:

- `http://localhost:3000` — QueryDesk (the default for an unrecognized host)
- `http://terradesk.localhost:3000` — TerraDesk

Use whichever port Next reports on startup; a `PORT` in the environment will
change it.

Chrome and Firefox resolve `*.localhost` on their own. If yours does not
(Safari, for one), add a line to `/etc/hosts`:

```
127.0.0.1 terradesk.localhost querydesk.localhost
```

## Customizing

You can start editing this template by modifying the files in the `/src` folder. The site will auto-update as you edit these files.

## Global search

This template includes a global search that's powered by the [FlexSearch](https://github.com/nextapps-de/flexsearch) library. It's available by clicking the search input or by using the `⌘K` shortcut.

This feature requires no configuration, and works out of the box by automatically scanning your documentation pages to build its index. You can adjust the search parameters by editing the `/src/mdx/search.mjs` file.

## License

This site template is a commercial product and is licensed under the [Tailwind UI license](https://tailwindui.com/license).

## Learn more

To learn more about the technologies used in this site template, see the following resources:

- [Tailwind CSS](https://tailwindcss.com/docs) - the official Tailwind CSS documentation
- [Next.js](https://nextjs.org/docs) - the official Next.js documentation
- [Headless UI](https://headlessui.dev) - the official Headless UI documentation
- [Framer Motion](https://www.framer.com/docs/) - the official Framer Motion documentation
- [MDX](https://mdxjs.com/) - the official MDX documentation
- [Algolia Autocomplete](https://www.algolia.com/doc/ui-libraries/autocomplete/introduction/what-is-autocomplete/) - the official Algolia Autocomplete documentation
- [FlexSearch](https://github.com/nextapps-de/flexsearch) - the official FlexSearch documentation
- [Zustand](https://docs.pmnd.rs/zustand/getting-started/introduction) - the official Zustand documentation
