<?php
// $Id$

/**
 * @file
 * Simple 2d vector class
 *
 * Provides addition, subtraction, and scaling.
 */

class Vector2d {
  public $x, $y;

  public function __construct($x, $y) {
    $this->x = $x;
    $this->y = $y;
  }

  public function add($vector) {
    return new Vector2d($this->x + $vector->x, $this->y + $vector->y);
  }

  public function subtract($vector) {
    return new Vector2d($this->x - $vector->x, $this->y - $vector->y);
  }

  public function scale($constant) {
    return new Vector2d($this->x * $constant, $this->y * $constant);
  }
}
