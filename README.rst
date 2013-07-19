Scratch.vim
===========

One of the best scratch window experiences ever. Inspired by scratch.vim_, enhanced.


Command and mappings
--------------------

This plugin provides a unique command, ``:Scratch``, which opens a scratch
buffer in a full-width window at the top of your screen. This buffer exists
until VIM is closed.

You can use the ``:Scratch!`` version of the command to reset the scratch
buffer before opening it.

There are two mappings in normal mode: ``gs`` and ``gS`` (mnemonic: 'go
scratch!') which correspond to the two previous commands respectively.
In visual mode, ``gs`` will append the lines selected to the scratch
buffer before opening it.


Configuration
-------------

* ``g:scratch_autohide``, by default the scratch window closes automatically
  when leaving the buffer. Set this to 0 to disable this behavior [default: 1].
* ``g:scratch_height``, the height of the scratch buffer window [default: 10].


Bonus
-----

For your convenience ``:sleep``, originally ``gs``, has been remapped to
``gZzZz``.


.. _scratch.vim: https://github.com/vim-scripts/scratch.vim
