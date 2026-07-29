import React, { useEffect, useState, useMemo } from 'react';
import { 
  Box, Typography, TextField, Paper, CircularProgress, 
  Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Alert, IconButton
} from '@mui/material';
import EditIcon from '@mui/icons-material/Edit';
import { useDispatch, useSelector } from 'react-redux';
import { fetchGlobalTeachers } from '../redux/teachersSlice';
import type { RootState, AppDispatch } from '../redux/store';
import EditTeacherDialog from '../components/EditTeacherDialog';

const TeachersDirectory: React.FC = () => {
  const dispatch = useDispatch<AppDispatch>();
  const { teachers, loading, error } = useSelector((state: RootState) => state.teachers);
  const [searchQuery, setSearchQuery] = useState('');
  
  const [editDialogOpen, setEditDialogOpen] = useState(false);
  const [selectedTeacherId, setSelectedTeacherId] = useState<string | number | null>(null);

  useEffect(() => {
    dispatch(fetchGlobalTeachers());
  }, [dispatch]);

  const filteredTeachers = useMemo(() => {
    return teachers.filter(teacher => 
      teacher.name.toLowerCase().includes(searchQuery.toLowerCase())
    );
  }, [teachers, searchQuery]);

  return (
    <Box sx={{ p: 3, maxWidth: 1200, margin: '0 auto' }}>
      <Typography variant="h4" gutterBottom color="primary" sx={{ fontWeight: 'bold' }}>
        دليل المعلمين
      </Typography>

      <Box sx={{ mb: 4 }}>
        <TextField
          fullWidth
          variant="outlined"
          placeholder="ابحث عن معلم..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          sx={{ backgroundColor: 'white' }}
        />
      </Box>

      {error && (
        <Alert severity="error" sx={{ mb: 3 }}>
          {error}
        </Alert>
      )}

      {loading ? (
        <Box sx={{ display: 'flex', justifyContent: 'center', my: 4 }}>
          <CircularProgress />
        </Box>
      ) : filteredTeachers.length === 0 ? (
        <Alert severity="info">
          لا يوجد معلمين يطابقون بحثك.
        </Alert>
      ) : (
        <Paper variant="outlined" sx={{ overflow: 'hidden' }}>
          <TableContainer>
            <Table size="small">
              <TableHead sx={{ bgcolor: 'grey.100' }}>
                <TableRow>
                  <TableCell><strong>الاسم</strong></TableCell>
                  <TableCell><strong>رقم الهاتف</strong></TableCell>
                  <TableCell><strong>البريد الإلكتروني</strong></TableCell>
                  <TableCell align="center"><strong>الإجراءات</strong></TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {filteredTeachers.map((teacher) => (
                  <TableRow key={teacher.id} hover>
                    <TableCell>{teacher.name}</TableCell>
                    <TableCell>{teacher.phone}</TableCell>
                    <TableCell>{teacher.email || '—'}</TableCell>
                    <TableCell align="center">
                      <IconButton 
                        color="primary" 
                        size="small"
                        onClick={() => {
                          setSelectedTeacherId(teacher.id);
                          setEditDialogOpen(true);
                        }}
                      >
                        <EditIcon />
                      </IconButton>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </TableContainer>
        </Paper>
      )}

      <EditTeacherDialog 
        open={editDialogOpen}
        teacherId={selectedTeacherId}
        onClose={() => {
          setEditDialogOpen(false);
          setSelectedTeacherId(null);
        }}
      />
    </Box>
  );
};

export default TeachersDirectory;
