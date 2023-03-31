import React, { useEffect, useState, useCallback } from 'react';
import { Box, Button as MUIButton } from '@mui/material';
import { connect } from 'react-redux'

import { CKEditor } from '@ckeditor/ckeditor5-react'

import ClassicEditor from '@ckeditor/ckeditor5-editor-classic/src/classiceditor';
import Alignment from '@ckeditor/ckeditor5-alignment/src/alignment.js';
import Autoformat from '@ckeditor/ckeditor5-autoformat/src/autoformat.js';
import BlockQuote from '@ckeditor/ckeditor5-block-quote/src/blockquote.js';
import Essentials from '@ckeditor/ckeditor5-essentials/src/essentials';
import Bold from '@ckeditor/ckeditor5-basic-styles/src/bold';
import Italic from '@ckeditor/ckeditor5-basic-styles/src/italic';
import Code from '@ckeditor/ckeditor5-basic-styles/src/code';

import Paragraph from '@ckeditor/ckeditor5-paragraph/src/paragraph';
import FontSize from '@ckeditor/ckeditor5-font/src/fontsize.js';
import FontFamily from '@ckeditor/ckeditor5-font/src/fontfamily.js';
import FontColor from '@ckeditor/ckeditor5-font/src/fontcolor.js';
import Heading from '@ckeditor/ckeditor5-heading/src/heading.js';
import Indent from '@ckeditor/ckeditor5-indent/src/indent.js';
import IndentBlock from '@ckeditor/ckeditor5-indent/src/indentblock.js';
import Link from '@ckeditor/ckeditor5-link/src/link.js';
import List from '@ckeditor/ckeditor5-list/src/list.js';

import './editor.css'

const editorConfiguration = {
  plugins: [
    Alignment,
    Autoformat,
    BlockQuote,
    Bold,
    Code,
    Essentials,
    FontSize,
    FontFamily,
    FontColor,
    Heading,
    Indent,
    IndentBlock,
    Italic,
    Link,
    List,
    Paragraph
  ],
  toolbar: [
    'heading',
    '|',
    'bold',
    'italic',
    'code',
    'link',
    '|',
    'blockQuote',
    'bulletedList',
    'numberedList',
    '|',
    'outdent',
    'indent',
    '|',
    'alignment',
    '|',
    'fontSize',
    'fontFamily',
    'fontColor',
    '|',
    'undo',
    'redo'
  ],
  link: {
    decorators: {
      openInNewTab: {
        mode: 'manual',
        label: 'Open in a new tab',
        defaultValue: true,         // This option will be selected by default.
        attributes: {
          target: '_blank',
          rel: 'noopener noreferrer'
        }
      }
    }
  },
  indentBlock: {
    offset: 1,
    unit: 'em'
  },
  fontSize: {
    options: [
      {
        title: 'Tiny',
        model: '12px'
      },
      {
        title: 'Small',
        model: '14px'
      },
      'default',
      {
        title: 'Big',
        model: '18px'
      },
      {
        title: 'Huge',
        model: '20px'
      }
    ]
  },
  fontColor: {
    colors: [
      {
        color: 'hsl(0, 0%, 0%)',
        label: 'Black'
      },
      {
        color: 'hsl(0, 0%, 30%)',
        label: 'Dim grey'
      },
      {
        color: 'hsl(0, 0%, 60%)',
        label: 'Grey'
      },
      {
        color: 'hsl(0, 0%, 90%)',
        label: 'Light grey'
      },
      {
        color: 'hsl(0, 75%, 60%)',
        label: 'Red'
      },
      {
        color: 'hsl(30, 75%, 60%)',
        label: 'Orange'
      },
      {
        color: 'hsl(60, 75%, 60%)',
        label: 'Yellow'
      },
      {
        color: 'hsl(90, 75%, 60%)',
        label: 'Light green'
      },
      {
        color: 'hsl(120, 75%, 60%)',
        label: 'Green'
      },
      {
        color: 'hsl(150, 75%, 60%)',
        label: 'Aquamarine'
      },
      {
        color: 'hsl(180, 75%, 60%)',
        label: 'Turquoise'
      },
      {
        color: 'hsl(210, 75%, 60%)',
        label: 'Light blue'
      },
      {
        color: 'hsl(240, 75%, 60%)',
        label: 'Blue'
      },
      {
        color: 'hsl(270, 75%, 60%)',
        label: 'Purple'
      }
    ]
  }
};


function TemplateEditor(props) {
  const [editor, setEditor] = useState(null)

  useEffect(() => {
    if (props.template?.status === "success") {
      const html = props.template.data.template
      if (!editor) { return }
      editor.setData(html)
    }
  }, [props.template, editor])


  function handleSubmit(event) {
    event.preventDefault();
    if (!editor) { return }
    const data = editor.getData();
    props.handleSubmit(data)
  }

  return (
    <Box
      sx={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'end'
      }}
    >
      <Box
        sx={{
          background: '#fff',
          width: '100%',
        }}
      >
        <CKEditor
          editor={ClassicEditor}
          data="<p>Welcome to the template editor</p>"
          config={editorConfiguration}
          onReady={editor => {
            // store the "editor" and use when it is needed.
            setEditor(editor)
          }}
        />
      </Box>
      <MUIButton
        variant="contained"
        onClick={handleSubmit}
        sx={{
          mt: 2
        }}
        disabled={props.save?.status === "pending"}
      >
        Save
      </MUIButton>
    </Box>
  )
}

const mapStateToProps = state => ({
  template: state.email_templates?.template,
  save: state.email_templates?.save
})

export default connect(mapStateToProps, {})(TemplateEditor)