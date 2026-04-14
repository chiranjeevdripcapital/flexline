import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom'
import { AppShell } from './components/AppShell'
import { BankAccounts } from './pages/BankAccounts'
import { Dashboard } from './pages/Dashboard'
import { Login } from './pages/Login'
import { Repayments } from './pages/Repayments'
import { RequestDraw } from './pages/RequestDraw'

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<Login />} />
        <Route element={<AppShell />}>
          <Route index element={<Dashboard />} />
          <Route path="bank-accounts" element={<BankAccounts />} />
          <Route path="request-draw" element={<RequestDraw />} />
          <Route path="repayments" element={<Repayments />} />
        </Route>
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </BrowserRouter>
  )
}
