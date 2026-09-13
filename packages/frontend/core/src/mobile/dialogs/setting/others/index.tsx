import { useI18n } from '@affine/i18n';

import { SettingGroup } from '../group';
import { RowLayout } from '../row.layout';

export const OthersGroup = () => {
  const t = useI18n();

  return (
    <SettingGroup title={t['com.affine.mobile.setting.others.title']()}>
      <RowLayout
        label={t['com.affine.mobile.setting.others.discord']()}
        href="https://discord.com/invite/whd5mjYqVw"
      />
      <RowLayout
        label={t['com.affine.mobile.setting.others.github']()}
        href="https://github.com/toeverything/Zeshan"
      />

      <RowLayout
        label={t['com.affine.mobile.setting.others.website']()}
        href="https://canvyst.techyst.net/home"
      />

      <RowLayout
        label={t['com.affine.mobile.setting.others.privacy']()}
        href="https://canvyst.techyst.net/home/privacy/"
      />

      <RowLayout
        label={t['com.affine.mobile.setting.others.terms']()}
        href="https://canvyst.techyst.net/home/terms/"
      />
    </SettingGroup>
  );
};
