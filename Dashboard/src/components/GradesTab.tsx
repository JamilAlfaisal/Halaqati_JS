import React, { useState, useEffect } from 'react';
import { Box, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Paper } from '@mui/material';
import { Dayjs } from 'dayjs';
import { useDispatch } from 'react-redux';
import { fetchGradesStats } from '../redux/classesSlice';
import type { AppDispatch } from '../redux/store';

interface GradesTabProps {
  classId: number;
  startDate: Dayjs | null;
  endDate: Dayjs | null;
}

const GradesTab: React.FC<GradesTabProps> = ({ classId, startDate, endDate }) => {
  const dispatch = useDispatch<AppDispatch>();
  const [students, setStudents] = useState<any[]>([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (startDate && endDate && classId) {
      setLoading(true);
      dispatch(fetchGradesStats({ 
        classId, 
        startDate: startDate.format('YYYY-MM-DD'), 
        endDate: endDate.format('YYYY-MM-DD') 
      }))
      .unwrap()
      .then((res) => {
        setStudents(res.data || []);
      })
      .catch((err) => console.error(err))
      .finally(() => setLoading(false));
    }
  }, [classId, startDate, endDate, dispatch]);

  return (
    <Box>
      <TableContainer component={Paper} variant="outlined">
        <Table>
          <TableHead>
            <TableRow>
              <TableCell><strong>اسم الطالب</strong></TableCell>
              <TableCell align="center"><strong>النسبة التراكمية (CGPA)</strong></TableCell>
              <TableCell align="center"><strong>ممتاز</strong></TableCell>
              <TableCell align="center"><strong>جيد جداً</strong></TableCell>
              <TableCell align="center"><strong>جيد</strong></TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {loading ? (
              <TableRow>
                <TableCell colSpan={5} align="center">جاري التحميل...</TableCell>
              </TableRow>
            ) : students.length === 0 ? (
              <TableRow>
                <TableCell colSpan={5} align="center">لا توجد بيانات درجات في هذه الفترة</TableCell>
              </TableRow>
            ) : (
              students.map((student) => (
                <TableRow key={student.studentId}>
                  <TableCell>{student.studentName}</TableCell>
                  <TableCell align="center">{student.cgpa}</TableCell>
                  <TableCell align="center">{student.cards?.perfect || 0}</TableCell>
                  <TableCell align="center">{student.cards?.veryGood || 0}</TableCell>
                  <TableCell align="center">{student.cards?.good || 0}</TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </TableContainer>
    </Box>
  );
};

export default GradesTab;
