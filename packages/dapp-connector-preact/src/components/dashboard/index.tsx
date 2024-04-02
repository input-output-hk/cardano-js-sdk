import './dashboard.css';
import { Logs, WalletActions } from '..';

export const Dashboard = () => (
  <div class="dashboard-container">
    <WalletActions />
    <Logs />
  </div>
);
