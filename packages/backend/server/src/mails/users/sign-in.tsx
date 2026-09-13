import {
  Button,
  Content,
  OnelineCodeBlock,
  P,
  SecondaryText,
  Template,
  Title,
} from '../components';

export type SignInProps = {
  url: string;
  otp: string;
  serverName?: string;
};

export default function SignIn(props: SignInProps) {
  return (
    <Template>
      <Title>{`Sign in to ${props.serverName ?? 'Canvyst'}`}</Title>
      <Content>
        <P>You are signing in to Canvyst. Here is your code:</P>
        <OnelineCodeBlock>{props.otp}</OnelineCodeBlock>
        <P>
          Alternatively, you can sign in directly by clicking the magic link
          below:
        </P>
        <Button href={props.url}>Sign in with Magic Link</Button>
        <P>
          <SecondaryText>
            This code and link will expire in 30 minutes.
          </SecondaryText>
        </P>
      </Content>
    </Template>
  );
}

SignIn.PreviewProps = {
  url: 'https://example.com',
  otp: '123456',
};
