import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { useSelector } from 'react-redux';
import type { RootState } from '../redux/store';
import Login from '../pages/Login';
import AdminLayout from '../components/AdminLayout';
import DashboardHome from '../pages/DashboardHome';
import ClassesList from '../pages/ClassesList';
import ClassDetail from '../pages/ClassDetail';
import ClassForm from '../pages/ClassForm';
import CreateAccount from '../pages/CreateAccount';
import StudentsDirectory from '../pages/StudentsDirectory';
import TeachersDirectory from '../pages/TeachersDirectory';

const AppRoutes: React.FC = () => {
  const isAuthenticated = useSelector((state: RootState) => state.auth.isAuthenticated);

  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={!isAuthenticated ? <Login /> : <Navigate to="/" replace />} />
        
        {/* Protected Routes */}
        <Route path="/" element={isAuthenticated ? <AdminLayout /> : <Navigate to="/login" replace />}>
          <Route index element={<DashboardHome />} />
          <Route path="classes" element={<ClassesList />} />
          <Route path="classes/create" element={<ClassForm />} />
          <Route path="classes/edit/:id" element={<ClassForm />} />
          <Route path="classes/:id" element={<ClassDetail />} />
          <Route path="students" element={<StudentsDirectory />} />
          <Route path="teachers" element={<TeachersDirectory />} />
          <Route path="create-account" element={<CreateAccount />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
};

export default AppRoutes;
