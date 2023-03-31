import React from 'react';
import clsx from 'clsx';
import { makeStyles } from '@material-ui/core/styles';
import { 
  Button, Modal, Paper, 
  Table, TableBody, TableCell, TableSortLabel,
  TableContainer, TableHead, TableRow,
  Typography, IconButton, Tooltip, Toolbar,
  Checkbox, Switch
} from '@material-ui/core';
import DeleteIcon from '@material-ui/icons/Delete';
import FilterListIcon from '@material-ui/icons/FilterList';
import EditIcon from '@material-ui/icons/Edit';

const isBoolean = val => 'boolean' === typeof val;


function descendingComparator(a, b, orderBy) {
  // case insensitive sorting
  if (typeof a[orderBy] === 'string' && typeof b[orderBy] === 'string') {
    return b[orderBy].localeCompare(a[orderBy], undefined, {sensitivity: 'base'})
  }

  if (b[orderBy] < a[orderBy]) {
    return -1;
  }
  if (b[orderBy] > a[orderBy]) {
    return 1;
  }
  return 0;
}

function getComparator(order, orderBy, sortFunc) {
  if (typeof sortFunc !== 'undefined') {
    return order === 'desc'
      ? (a, b) => sortFunc(a, b, orderBy)
      : (a, b) => -sortFunc(a, b, orderBy)
  }
  return order === 'desc'
  ? (a, b) => descendingComparator(a, b, orderBy)
  : (a, b) => -descendingComparator(a, b, orderBy)
}

function stableSort(array, comparator) {
  const stabilizedThis = array.map((el, index) => [el, index]);
  stabilizedThis.sort((a, b) => {
    const order = comparator(a[0], b[0]);
    if (order !== 0) return order;
    return a[1] - b[1];
  });
  return stabilizedThis.map((el) => el[0]);
}

const useToolbarStyles = makeStyles((theme) => ({
  root: {
    paddingLeft: theme.spacing(2),
    paddingRight: theme.spacing(1),
  },
  highlight: {
    color: theme.palette.text.primary,
    backgroundColor: theme.palette.primary.dark
  },
  title: {
    flex: '1 1 100%',
  },
}));

const EnhancedTableToolbar = (props) => {
  const classes = useToolbarStyles();
  const { numSelected } = props;

  return (
    <Toolbar
      className={clsx(classes.root, {
        [classes.highlight]: numSelected > 0,
      })}
    >
      {numSelected > 0 ? (
        <Typography className={classes.title} color="inherit" variant="subtitle1" component="div">
          {numSelected} selected
        </Typography>
      ) : (
        <Typography className={classes.title} variant="h6" id="tableTitle" component="div">
          {props.title}
        </Typography>
      )}

      {numSelected > 0 ? (
        <React.Fragment>
          {numSelected === 1 ? (
            <Tooltip PopperProps={{disablePortal: true}} arrow title="Edit">
              <IconButton aria-label="edit" onClick={props.handleEdit}>
                <EditIcon/>
              </IconButton>
            </Tooltip>
          ) : null} 
          <Tooltip PopperProps={{disablePortal: true}} arrow title="Delete">
            <IconButton aria-label="delete" onClick={props.handleDelete}>
              <DeleteIcon />
            </IconButton>
          </Tooltip>
        </React.Fragment>
      ) : (
        <Tooltip PopperProps={{disablePortal: true}} arrow title="Filter list">
          <IconButton aria-label="filter list">
            <FilterListIcon />
          </IconButton>
        </Tooltip>
      )}
    </Toolbar>
  );
};

function EnhancedTableHead(props) {
  const { classes, onSelectAllClick, order, orderBy, numSelected, rowCount, onRequestSort, columns } = props;
  const createSortHandler = (property, sortFunc) => (event) => {
    onRequestSort(event, property, sortFunc);
  };

  return (
    <TableHead className={classes.tableHead}>
      <TableRow>
        <TableCell className={classes.tableCell} padding="checkbox">
          <Checkbox
            indeterminate={numSelected > 0 && numSelected < rowCount}
            checked={rowCount > 0 && numSelected === rowCount}
            onChange={onSelectAllClick}
            inputProps={{ 'aria-label': 'Select all commands' }}
          />
        </TableCell>
        {columns.map(column => (
          <TableCell
            className={classes.tableCell}
            key={column.field}
            sortDirection={orderBy === column.field ? order : false}
            align={column.switch ? 'center' : 'left'}
          >
            {column.sortable ? <TableSortLabel
              active={orderBy === column.field}
              direction={orderBy === column.field ? order : 'asc'}
              onClick={createSortHandler(column.field, column.sortFunc)}
            >
              {column.headerName}
              {orderBy === column.field ? (
                <span className={classes.visuallyHidden}>
                  {order === 'desc' ? 'sorted descending' : 'sorted ascending'}
                </span>
              ) : null}
            </TableSortLabel> : column.headerName}
            
          </TableCell>
        ))}
      </TableRow>
    </TableHead>
  )
}


const useStyles = makeStyles(theme => ({
  root: {
    width: '100%',
    padding: theme.spacing(2),
    backgroundColor: theme.palette.background.paperLight,
  },
  paper: {
    width: '100%',
    marginBottom: theme.spacing(2),
  },
  table: {
    minWidth: 750,
  },
  visuallyHidden: {
    border: 0,
    clip: 'rect(0 0 0 0)',
    height: 1,
    margin: -1,
    overflow: 'hidden',
    padding: 0,
    position: 'absolute',
    top: 20,
    width: 1,
  },
  tableContainer: {
    backgroundColor: theme.palette.background.paperLight,
    '&.MuiPaper-outlined': {
      borderColor: theme.palette.background.paper
    }
  },
  tableRow: {
    '&:last-child .MuiTableCell-root': {
      borderBottom: 'none'
    }
  },
  tableCell: {
    borderBottom: `1px solid ${theme.palette.background.paper}`,
  },
  tableHead: {
    backgroundColor: theme.palette.background.paper
  },
}))

export default function CommandTable(props) {
  const classes = useStyles()
  const { columns, rows, id } = props
  const [selected, setSelected] = React.useState([])
  const [order, setOrder] = React.useState('asc');
  const [orderBy, setOrderBy] = React.useState(columns[0].field);
  const [sortFunc, setSortFunc] = React.useState()

  function handleRequestSort(event, property, sortFunc) {
    const isAsc = orderBy === property && order === 'asc';
    setOrder(isAsc ? 'desc' : 'asc');
    setOrderBy(property);
    setSortFunc(() => sortFunc)
  };

  function handleDelete() {
    props.handleDelete(selected)
    setSelected([]);
  }

  function handleEdit() {
    props.handleEdit(selected)
  }

  function handleSelectAllClick(event) {
    if (event.target.checked) {
      const newSelecteds = rows.map((row) => row[id]);
      setSelected(newSelecteds);
      return;
    }
    setSelected([]);
  };

  function handleBooleanChange(event, field, row) {
    props.handleBooleanChange(event, field, row)
  }

  function handleClick(event, id) {
    const selectedIndex = selected.indexOf(id);
    let newSelected = [];

    if (selectedIndex === -1) {
      newSelected = newSelected.concat(selected, id);
    } else if (selectedIndex === 0) {
      newSelected = newSelected.concat(selected.slice(1));
    } else if (selectedIndex === selected.length - 1) {
      newSelected = newSelected.concat(selected.slice(0, -1));
    } else if (selectedIndex > 0) {
      newSelected = newSelected.concat(
        selected.slice(0, selectedIndex),
        selected.slice(selectedIndex + 1),
      );
    }

    setSelected(newSelected);
  };

  const isSelected = (name) => selected.indexOf(name) !== -1;

  return (
    <div className={classes.root}>
      <TableContainer className={classes.tableContainer} variant="outlined" component={Paper}>
        <EnhancedTableToolbar title={props.title} numSelected={selected.length} handleDelete={handleDelete} handleEdit={handleEdit}/>
        <Table>
          <EnhancedTableHead
            columns={columns}
            classes={classes}
            onSelectAllClick={handleSelectAllClick}
            onRequestSort={handleRequestSort}
            order={order}
            orderBy={orderBy}
            rowCount={rows.length}
            numSelected={selected.length}
          />
          <TableBody>
            {stableSort(rows, getComparator(order, orderBy, sortFunc))
              .map((row, index) => {
                const isItemSelected = isSelected(row[id])
                const labelId = `enhanced-table-checkbox-${index}`;
                return (
                  <TableRow 
                    hover 
                    key={row[id]}
                    onClick={(event) => handleClick(event, row[id])}
                    role="checkbox"
                    aria-checked={isItemSelected}
                    tabIndex={-1}
                    selected={isItemSelected}
                    className={classes.tableRow}
                  >
                    <TableCell className={classes.tableCell} padding="checkbox">
                      <Checkbox
                        checked={isItemSelected}
                        inputProps={{ 'aria-labelledby': labelId }}
                      />
                    </TableCell>
                    {columns.map((column, index) => (
                      column.field in row ? 
                      <TableCell
                        className={classes.tableCell} 
                        key={index}
                        align={column.switch ? 'center' : 'left'}
                      >
                        {isBoolean(row[column.field]) ? 
                          <Switch
                            checked={row[column.field]}
                            onClick={(event) => event.stopPropagation()}
                            onChange={(event) => handleBooleanChange(event, column.field, row)}
                            color="primary"
                          /> : row[column.field]
                        }
                      </TableCell> : null
                    ))}
                  </TableRow>
                )
              })
            }
          </TableBody>
        </Table>
      </TableContainer>
    </div>
  )
}
