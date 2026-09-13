import type { Package } from '@affine-tools/utils/workspace';

import { PackageToDistribution } from './distribution';

/**
 * The Canvyst product site.
 *
 * The workspace application owns the root of its host, so the marketing and
 * documentation pages are served under /home. Overridable at build time so a
 * differently-hosted deployment does not need a patch.
 */
const CANVASYST_SITE =
  process.env.CANVASYST_SITE_URL ?? 'https://canvyst.techyst.net/home';

export interface BuildFlags {
  channel: 'stable' | 'beta' | 'internal' | 'canary';
  mode: 'development' | 'production';
}

export function getBuildConfig(
  pkg: Package,
  buildFlags: BuildFlags
): BUILD_CONFIG_TYPE {
  const distribution = PackageToDistribution.get(pkg.name);

  if (!distribution) {
    throw new Error(`Distribution for ${pkg.name} is not found`);
  }

  const buildPreset: Record<BuildFlags['channel'], BUILD_CONFIG_TYPE> = {
    get stable() {
      return {
        debug: buildFlags.mode === 'development',
        distribution,
        isDesktopEdition: (
          ['web', 'desktop', 'admin'] as BUILD_CONFIG_TYPE['distribution'][]
        ).includes(distribution),
        isMobileEdition: (
          ['mobile', 'ios', 'android'] as BUILD_CONFIG_TYPE['distribution'][]
        ).includes(distribution),
        isElectron: distribution === 'desktop',
        isWeb: distribution === 'web',
        isMobileWeb: distribution === 'mobile',
        isIOS: distribution === 'ios',
        isAndroid: distribution === 'android',
        isNative:
          distribution === 'desktop' ||
          distribution === 'ios' ||
          distribution === 'android',
        isAdmin: distribution === 'admin',

        appBuildType: 'stable' as const,
        appVersion: pkg.version,
        // editorVersion: pkg.dependencies['@blocksuite/affine'],
        editorVersion: pkg.version,
        // Outbound links shown in the UI. Every one of these must resolve to a
        // page that is actually served: they surface in Settings, in the
        // sidebar and in update prompts, and a dead link there is worse than
        // no link. The product site lives under /home because the workspace
        // owns the root of its host.
        //
        // githubUrl points at the upstream project, which is where the editor
        // is actually developed — not at a Canvyst repository that does not
        // exist.
        githubUrl: 'https://github.com/toeverything/AFFiNE',
        changelogUrl: `${CANVASYST_SITE}/changelog/`,
        downloadUrl: CANVASYST_SITE,
        pricingUrl: `${CANVASYST_SITE}/#capabilities`,
        discordUrl: `${CANVASYST_SITE}/community/`,
        requestLicenseUrl: `${CANVASYST_SITE}/support/`,
        imageProxyUrl: '/api/worker/image-proxy',
        linkPreviewUrl: '/api/worker/link-preview',
        SENTRY_DSN: process.env.SENTRY_DSN ?? '',
      };
    },
    get beta() {
      return {
        ...this.stable,
        appBuildType: 'beta' as const,
      };
    },
    get internal() {
      return {
        ...this.stable,
        appBuildType: 'internal' as const,
      };
    },
    // canary will be aggressive and enable all features
    get canary() {
      return {
        ...this.stable,
        appBuildType: 'canary' as const,
      };
    },
  };

  const currentBuild = buildFlags.channel;

  if (!(currentBuild in buildPreset)) {
    throw new Error(`BUILD_TYPE ${currentBuild} is not supported`);
  }

  const currentBuildPreset = buildPreset[currentBuild];

  const environmentPreset = {
    changelogUrl: process.env.CHANGELOG_URL ?? currentBuildPreset.changelogUrl,
  };

  return {
    ...currentBuildPreset,
    // environment preset will overwrite current build preset
    // this environment variable is for debug proposes only
    // do not put them into CI
    ...(process.env.CI ? {} : environmentPreset),
  };
}
