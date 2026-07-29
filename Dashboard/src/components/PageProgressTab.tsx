import React, { useState, useEffect } from 'react';
import { 
  Box, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Paper, 
  IconButton, Collapse, Typography, CircularProgress 
} from '@mui/material';
import KeyboardArrowDownIcon from '@mui/icons-material/KeyboardArrowDown';
import KeyboardArrowUpIcon from '@mui/icons-material/KeyboardArrowUp';
import { useDispatch } from 'react-redux';
import { fetchPageProgressSummary, fetchStudentPageProgress } from '../redux/classesSlice';
import type { AppDispatch } from '../redux/store';
import { getPageColor } from '../utils/colors';

interface PageProgressTabProps {
  classId: number;
}

const StudentProgressRow = ({ student, classId }: { student: any, classId: number }) => {
  const dispatch = useDispatch<AppDispatch>();
  const [open, setOpen] = useState(false);
  const [loading, setLoading] = useState(false);
  const [progressDetails, setProgressDetails] = useState<any[] | null>(null);

  const handleExpand = () => {
    if (!open && progressDetails === null) {
      setLoading(true);
      dispatch(fetchStudentPageProgress({ classId, studentId: student.studentId }))
        .unwrap()
        .then((res) => {
          setProgressDetails(res.data);
        })
        .catch(err => console.error(err))
        .finally(() => setLoading(false));
    }
    setOpen(!open);
  };

  return (
    <React.Fragment>
      <TableRow sx={{ '& > *': { borderBottom: 'unset' } }}>
        <TableCell>
          <IconButton aria-label="expand row" size="small" onClick={handleExpand}>
            {open ? <KeyboardArrowUpIcon /> : <KeyboardArrowDownIcon />}
          </IconButton>
        </TableCell>
        <TableCell component="th" scope="row">
          {student.studentName}
        </TableCell>
        <TableCell align="center">
          <strong>{student.juzCount} / 30</strong>
        </TableCell>
      </TableRow>
      <TableRow>
        <TableCell style={{ paddingBottom: 0, paddingTop: 0 }} colSpan={3}>
          <Collapse in={open} timeout="auto" unmountOnExit>
            <Box sx={{ margin: 2 }}>
              <Typography variant="h6" gutterBottom component="div">
                الصفحات المحفوظة (ملونة حسب تاريخ المراجعة)
              </Typography>
              
              {loading && <CircularProgress size={24} />}
              
              {!loading && progressDetails && progressDetails.length === 0 && (
                <Typography color="textSecondary">لا توجد صفحات محفوظة.</Typography>
              )}

              {!loading && progressDetails && progressDetails.length > 0 && (
                <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 1, mt: 1 }}>
                  {progressDetails.map((p) => {
                    const bgColor = getPageColor(p.reviewDate);
                    // Determine text color for contrast (white for dark colors, black for light)
                    // The yellow700 and blue are fairly dark, but we can default to white text.
                    return (
                      <Box
                        key={p.pageNumber}
                        sx={{
                          width: 40,
                          height: 40,
                          bgcolor: bgColor,
                          color: '#fff',
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'center',
                          borderRadius: 1,
                          fontWeight: 'bold',
                          fontSize: '0.875rem',
                          boxShadow: 1,
                          textShadow: '0px 1px 2px rgba(0,0,0,0.4)',
                        }}
                        title={`تاريخ المراجعة: ${p.reviewDate ? new Date(p.reviewDate).toLocaleDateString() : 'غير مراجع'}`}
                      >
                        {p.pageNumber}
                      </Box>
                    );
                  })}
                </Box>
              )}
              
              {!loading && progressDetails && progressDetails.length > 0 && (
                <Box sx={{ mt: 2, display: 'flex', gap: 2, alignItems: 'center' }}>
                  <Typography variant="caption" color="textSecondary">مفتاح الألوان:</Typography>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
                    <Box sx={{ width: 12, height: 12, bgcolor: getPageColor(new Date().toISOString()), borderRadius: 0.5 }}></Box>
                    <Typography variant="caption">جديد (0 يوم)</Typography>
                  </Box>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
                    <Box sx={{ width: 12, height: 12, bgcolor: getPageColor(new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString()), borderRadius: 0.5 }}></Box>
                    <Typography variant="caption">قديم (+7 أيام)</Typography>
                  </Box>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
                    <Box sx={{ width: 12, height: 12, bgcolor: getPageColor(null), borderRadius: 0.5 }}></Box>
                    <Typography variant="caption">غير مراجع</Typography>
                  </Box>
                </Box>
              )}

            </Box>
          </Collapse>
        </TableCell>
      </TableRow>
    </React.Fragment>
  );
};

const PageProgressTab: React.FC<PageProgressTabProps> = ({ classId }) => {
  const dispatch = useDispatch<AppDispatch>();
  const [students, setStudents] = useState<any[]>([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (classId) {
      setLoading(true);
      dispatch(fetchPageProgressSummary(classId))
        .unwrap()
        .then((res) => {
          setStudents(res.data || []);
        })
        .catch(err => console.error(err))
        .finally(() => setLoading(false));
    }
  }, [classId, dispatch]);

  return (
    <Box>
      <TableContainer component={Paper} variant="outlined">
        <Table>
          <TableHead>
            <TableRow>
              <TableCell style={{ width: 50 }} />
              <TableCell><strong>اسم الطالب</strong></TableCell>
              <TableCell align="center"><strong>عدد الأجزاء المكتملة</strong></TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {loading ? (
              <TableRow>
                <TableCell colSpan={3} align="center">جاري التحميل...</TableCell>
              </TableRow>
            ) : students.length === 0 ? (
              <TableRow>
                <TableCell colSpan={3} align="center">لا يوجد طلاب في هذه الحلقة</TableCell>
              </TableRow>
            ) : (
              students.map((student) => (
                <StudentProgressRow key={student.studentId} student={student} classId={classId} />
              ))
            )}
          </TableBody>
        </Table>
      </TableContainer>
    </Box>
  );
};

export default PageProgressTab;
