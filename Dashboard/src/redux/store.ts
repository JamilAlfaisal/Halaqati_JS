import { configureStore } from '@reduxjs/toolkit';
import authReducer from './authSlice';
import classesReducer from './classesSlice';
import studentsReducer from './studentsSlice';
import teachersReducer from './teachersSlice';

export const store = configureStore({
  reducer: {
    auth: authReducer,
    classes: classesReducer,
    students: studentsReducer,
    teachers: teachersReducer,
  },
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
