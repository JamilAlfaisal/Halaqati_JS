import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { useNavigate } from 'react-router-dom';
import { 
  Box, Typography, Button, Paper, Table, TableBody, TableCell, 
  TableContainer, TableHead, TableRow, IconButton, Dialog, 
  DialogTitle, DialogContent, DialogContentText, DialogActions,
  CircularProgress, Alert
} from '@mui/material';
import DeleteIcon from '@mui/icons-material/Delete';
import EditIcon from '@mui/icons-material/Edit';
import VisibilityIcon from '@mui/icons-material/Visibility';
import AddIcon from '@mui/icons-material/Add';
import { fetchAllClasses, deleteClass } from '../redux/classesSlice';
import type { AppDispatch, RootState } from '../redux/store';

const ClassesList: React.FC = () => {
  const dispatch = useDispatch<AppDispatch>();
  const navigate = useNavigate();
  const { classes, loading, error } = useSelector((state: RootState) => state.classes);
  
  const [deleteId, setDeleteId] = useState<number | null>(null);

  useEffect(() => {
    dispatch(fetchAllClasses());
  }, [dispatch]);

  const handleDeleteClick = (id: number) => {
    setDeleteId(id);
  };

  const handleConfirmDelete = async () => {
    if (deleteId) {
      await dispatch(deleteClass(deleteId));
      setDeleteId(null);
    }
  };

  return (
    <Box>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
        <Typography variant="h4" color="primary">إدارة الحلقات</Typography>
        <Button 
          variant="contained" 
          startIcon={<AddIcon />} 
          onClick={() => navigate('/classes/create')}
        >
          إضافة حلقة
        </Button>
      </Box>

      <TableContainer component={Paper} sx={{ borderRadius: 2 }}>
        <Table>
          <TableHead sx={{ bgcolor: 'grey.100' }}>
            <TableRow>
              <TableCell><strong>اسم الحلقة</strong></TableCell>
              <TableCell><strong>المعلم</strong></TableCell>
              <TableCell><strong>عدد الطلاب</strong></TableCell>
              <TableCell><strong>أيام الدوام</strong></TableCell>
              <TableCell><strong>الإجراءات</strong></TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {loading ? (
              <TableRow><TableCell colSpan={5} align="center" sx={{ py: 3 }}><CircularProgress size={30} /></TableCell></TableRow>
            ) : error ? (
              <TableRow><TableCell colSpan={5} align="center"><Alert severity="error">{error}</Alert></TableCell></TableRow>
            ) : classes.length === 0 ? (
              <TableRow><TableCell colSpan={5} align="center">لا توجد حلقات مسجلة</TableCell></TableRow>
            ) : (
              classes.map((cls) => (
                <TableRow key={cls.id} hover>
                  <TableCell>{cls.name}</TableCell>
                  <TableCell>{cls.teacherName}</TableCell>
                  <TableCell>{cls.studentsCount || 0}</TableCell>
                  <TableCell>{cls.days?.join('، ') || 'غير محدد'}</TableCell>
                  <TableCell>
                    <IconButton color="info" onClick={() => navigate(`/classes/${cls.id}`)}>
                      <VisibilityIcon />
                    </IconButton>
                    <IconButton color="primary" onClick={() => navigate(`/classes/edit/${cls.id}`)}>
                      <EditIcon />
                    </IconButton>
                    <IconButton color="error" onClick={() => handleDeleteClick(cls.id)}>
                      <DeleteIcon />
                    </IconButton>
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </TableContainer>

      {/* Delete Confirmation Dialog */}
      <Dialog open={!!deleteId} onClose={() => setDeleteId(null)}>
        <DialogTitle>تأكيد الحذف</DialogTitle>
        <DialogContent>
          <DialogContentText>
            هل أنت متأكد من رغبتلك في حذف هذه الحلقة؟ لا يمكن التراجع عن هذا الإجراء.
          </DialogContentText>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setDeleteId(null)}>إلغاء</Button>
          <Button onClick={handleConfirmDelete} color="error" variant="contained">
            حذف
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default ClassesList;
