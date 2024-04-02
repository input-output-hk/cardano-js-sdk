import './style.css';
import { Header } from './components/header';
import { Home } from './pages/Home';
import { NotFound } from './pages/_404';
import { Route, Router } from 'preact-router';
import { hydrate, prerender as ssr } from 'preact-iso';

export const App = () => (
  <>
    <Header />
    <main>
      <Router>
        <Route path="/" component={Home} />
        <Route path="/404" component={NotFound} />
      </Router>
    </main>
  </>
);

if (typeof window !== 'undefined') {
  hydrate(<App />, document.querySelector('#app')!);
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export const prerender = async (data: any) => await ssr(<App {...data} />);
