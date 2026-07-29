import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import apiClient from '../api/apiClient';

export interface GlobalStudent {
  studentId: string;
  studentName: string;
  className: string;
  juzCount: number;
}

interface StudentsState {
  directory: GlobalStudent[];
  loading: boolean;
  error: string | null;
}

const initialState: StudentsState = {
  directory: [],
  loading: false,
  error: null,
};

export const fetchGlobalStudentDirectory = createAsyncThunk(
  'students/fetchGlobalStudentDirectory',
  async (_, { rejectWithValue }) => {
    try {
      const response = await apiClient.get('/pages/admin/students/directory');
      return response.data;
    } catch (err: any) {
      return rejectWithValue(err.response?.data?.message || 'Failed to fetch global student directory');
    }
  }
);

export const updateStudentProfile = createAsyncThunk(
  'students/updateStudentProfile',
  async (
    payload: { id: string | number; name?: string; email?: string; phone?: string; password?: string; picProfile?: string; dob?: string },
    { rejectWithValue }
  ) => {
    try {
      const { id, ...data } = payload;
      const response = await apiClient.put(`/auth/update/${id}`, data);
      return response.data;
    } catch (err: any) {
      return rejectWithValue(err.response?.data?.message || 'Failed to update student profile');
    }
  }
);

export const studentsSlice = createSlice({
  name: 'students',
  initialState,
  reducers: {},
  extraReducers: (builder) => {
    builder
      .addCase(fetchGlobalStudentDirectory.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchGlobalStudentDirectory.fulfilled, (state, action) => {
        state.loading = false;
        state.directory = action.payload;
      })
      .addCase(fetchGlobalStudentDirectory.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload as string;
      });
  },
});

export default studentsSlice.reducer;
