import { useLocation } from 'preact-iso';

export const Header = () => {
  const { url } = useLocation();

  return (
    <header>
      <nav>
        <a href="/" className={url === '/' ? 'active' : undefined}>
          Home
        </a>
        <a href="/404" className={url === '/404' ? 'active' : undefined}>
          404
        </a>
      </nav>
    </header>
  );
};
