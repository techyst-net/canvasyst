import { DocIcon, GithubIcon, LinkIcon } from './icons';

/**
 * Pages on the Canvyst product site.
 *
 * Derived from BUILD_CONFIG rather than hard-coded so a differently-hosted
 * deployment can repoint them with CANVASYST_SITE_URL at build time. The site
 * lives under /home because the workspace owns the root of its host.
 */
const SITE = BUILD_CONFIG.downloadUrl;

export const canvasystLinks = {
  home: SITE,
  support: `${SITE}/support/`,
  community: `${SITE}/community/`,
  changelog: `${SITE}/changelog/`,
  privacy: `${SITE}/privacy/`,
  terms: `${SITE}/terms/`,
} as const;

/**
 * The "Communities" row on the About page.
 *
 * Upstream listed its own X, Discord, YouTube and Reddit accounts here.
 * Canvyst has no such accounts, and an earlier rename had left the surviving
 * entries pointing at addresses that were never registered. Every entry below
 * resolves to a page that is actually served — if Techyst opens social accounts
 * later, add them here.
 */
export const relatedLinks = [
  {
    icon: <LinkIcon />,
    title: 'Community',
    link: canvasystLinks.community,
  },
  {
    icon: <DocIcon />,
    title: 'Support',
    link: canvasystLinks.support,
  },
  {
    icon: <DocIcon />,
    title: 'Changelog',
    link: canvasystLinks.changelog,
  },
  {
    icon: <GithubIcon />,
    title: 'AFFiNE',
    link: BUILD_CONFIG.githubUrl,
  },
];
