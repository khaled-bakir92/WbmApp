"use client";

import { useState } from "react";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
  DialogDescription,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import { Loader2 } from "lucide-react";
import { DEFAULT_INTERVAL, MIN_INTERVAL, MAX_INTERVAL } from "@/lib/constants";

interface StartDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onConfirm: (interval: number, gui: boolean) => void;
  isPending: boolean;
  title?: string;
}

export function StartDialog({
  open,
  onOpenChange,
  onConfirm,
  isPending,
  title = "Start Bot",
}: StartDialogProps) {
  const [interval, setInterval] = useState(DEFAULT_INTERVAL);
  const [gui, setGui] = useState(false);

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>{title}</DialogTitle>
          <DialogDescription>
            Configure the bot before starting.
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-4 py-4">
          <div className="space-y-2">
            <Label htmlFor="interval">
              Check interval: {interval}s ({Math.round(interval / 60)} min)
            </Label>
            <Input
              id="interval"
              type="range"
              min={MIN_INTERVAL}
              max={MAX_INTERVAL}
              step={60}
              value={interval}
              onChange={(e) => setInterval(Number(e.target.value))}
              className="cursor-pointer"
            />
            <div className="flex justify-between text-xs text-muted-foreground">
              <span>1 min</span>
              <span>24 h</span>
            </div>
          </div>

          <div className="flex items-center justify-between">
            <Label htmlFor="gui">Browser GUI (non-headless)</Label>
            <Switch id="gui" checked={gui} onCheckedChange={setGui} />
          </div>
        </div>

        <DialogFooter>
          <Button variant="outline" onClick={() => onOpenChange(false)}>
            Cancel
          </Button>
          <Button
            onClick={() => onConfirm(interval, gui)}
            disabled={isPending}
          >
            {isPending && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
            {title}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
