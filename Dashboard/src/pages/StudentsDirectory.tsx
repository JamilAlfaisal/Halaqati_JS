import React, { useEffect, useState, useMemo } from 'react';
import { 
  Box, Typography, TextField, Paper, CircularProgress, 
  Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Alert, IconButton
} from '@mui/material';
import EditIcon from '@mui/icons-material/Edit';
import { useDispatch, useSelector } from 'react-redux';
import { fetchGlobalStudentDirectory } from '../redux/studentsSlice';
import type { RootState, AppDispatch } from '../redux/store';
import type { GlobalStudent } from '../redux/studentsSlice';
import EditStudentDialog from '../components/EditStudentDialog';

// Helper to format Juz count with proper Arabic grammar
const formatJuzCount = (count: number) => {
  if (count === 0) return '0 أجزاء';
  if (count === 1) return 'جزء واحد';
  if (count === 2) return 'جزءان';
  if (count >= 3 && count <= 10) return `${count} أجزاء`;
  return `${count} جزءًا`;
};

const StudentsDirectory: React.FC = () => {
  const dispatch = useDispatch<AppDispatch>();
  const { directory, loading, error } = useSelector((state: RootState) => state.students);
  const [searchQuery, setSearchQuery] = useState('');
  
  const [editDialogOpen, setEditDialogOpen] = useState(false);
  const [selectedStudentId, setSelectedStudentId] = useState<string | null>(null);

  useEffect(() => {
    dispatch(fetchGlobalStudentDirectory());
  }, [dispatch]);

  // Filter and group by juzCount
  const groupedStudents = useMemo(() => {
    // 1. Filter by search query
    const filtered = directory.filter(student => 
      student.studentName.toLowerCase().includes(searchQuery.toLowerCase())
    );

    // 2. Group by juzCount
    const groups: Record<number, GlobalStudent[]> = {};
    filtered.forEach(student => {
      if (!groups[student.juzCount]) {
        groups[student.juzCount] = [];
      }
      groups[student.juzCount].push(student);
    });

    // 3. Sort buckets descending (30 down to 0)
    const sortedCounts = Object.keys(groups).map(Number).sort((a, b) => b - a);

    return sortedCounts.map(count => ({
      juzCount: count,
      students: groups[count],
    }));
  }, [directory, searchQuery]);

  return (
    <Box sx={{ p: 3, maxWidth: 1200, margin: '0 auto' }}>
      <Typography variant="h4" gutterBottom color="primary" sx={{ fontWeight: 'bold' }}>
        دليل الطلاب
      </Typography>

      <Box sx={{ mb: 4 }}>
        <TextField
          fullWidth
          variant="outlined"
          placeholder="ابحث عن طالب..."
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
      ) : groupedStudents.length === 0 ? (
        <Alert severity="info">
          لا يوجد طلاب يطابقون بحثك.
        </Alert>
      ) : (
        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
          {groupedStudents.map(({ juzCount, students }) => (
            <Paper key={juzCount} variant="outlined" sx={{ overflow: 'hidden' }}>
              <Box sx={{ bgcolor: 'primary.main', color: 'primary.contrastText', p: 2 }}>
                <Typography variant="h6" sx={{ fontWeight: 'bold' }}>
                  {formatJuzCount(juzCount)}
                </Typography>
              </Box>
              <TableContainer>
                <Table size="small">
                  <TableHead>
                    <TableRow>
                      <TableCell><strong>اسم الطالب</strong></TableCell>
                      <TableCell><strong>الحلقة</strong></TableCell>
                      <TableCell align="center"><strong>الإجراءات</strong></TableCell>
                    </TableRow>
                  </TableHead>
                  <TableBody>
                    {students.map((student) => (
                      <TableRow key={student.studentId} hover>
                        <TableCell>{student.studentName}</TableCell>
                        <TableCell>{student.className}</TableCell>
                        <TableCell align="center">
                          <IconButton 
                            color="primary" 
                            size="small"
                            onClick={() => {
                              setSelectedStudentId(student.studentId);
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
          ))}
        </Box>
      )}

      <EditStudentDialog 
        open={editDialogOpen}
        studentId={selectedStudentId}
        onClose={() => {
          setEditDialogOpen(false);
          setSelectedStudentId(null);
        }}
      />
    </Box>
  );
};

export default StudentsDirectory;
