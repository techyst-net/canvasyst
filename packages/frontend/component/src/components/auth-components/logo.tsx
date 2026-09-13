/**
 * Brand lockup shown on the sign-in and sign-up screens.
 *
 * Keeps the original 149x48 viewBox and `currentColor` fill so every existing
 * call site keeps its sizing and theme behaviour; only the artwork is ours.
 */
export const Logo = () => {
  return (
    <svg
      width="149"
      height="48"
      viewBox="0 0 149 48"
      fill="currentColor"
      xmlns="http://www.w3.org/2000/svg"
      role="img"
      aria-label="Canvyst"
    >
      <g transform="translate(4 8) scale(0.5)">
        <path d="M18 18 H46 V26 L31 38 H46 V46 H18 V38 L33 26 H18 Z" />
      </g>
      <text
        x="42"
        y="32"
        fontFamily="Inter,-apple-system,BlinkMacSystemFont,Segoe UI,Roboto,sans-serif"
        fontSize="22"
        fontWeight="600"
        letterSpacing="-0.4"
        fill="currentColor"
      >
        Canvyst
      </text>
    </svg>
  );
};
