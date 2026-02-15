"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Play, Square, RotateCcw } from "lucide-react";
import { useBotStatus } from "@/hooks/use-bot-status";
import { useBotActions } from "@/hooks/use-bot-actions";
import { StartDialog } from "./start-dialog";
import { StopDialog } from "./stop-dialog";

export function BotControls() {
  const { data: status } = useBotStatus();
  const { start, stop, restart } = useBotActions();
  const running = status?.running ?? false;

  const [startOpen, setStartOpen] = useState(false);
  const [stopOpen, setStopOpen] = useState(false);
  const [restartOpen, setRestartOpen] = useState(false);

  return (
    <>
      <Card>
        <CardHeader>
          <CardTitle>Bot Actions</CardTitle>
        </CardHeader>
        <CardContent className="flex flex-wrap gap-3">
          <Button
            onClick={() => setStartOpen(true)}
            disabled={running}
            className="bg-green-600 hover:bg-green-700"
          >
            <Play className="mr-2 h-4 w-4" />
            Start
          </Button>
          <Button
            variant="destructive"
            onClick={() => setStopOpen(true)}
            disabled={!running}
          >
            <Square className="mr-2 h-4 w-4" />
            Stop
          </Button>
          <Button
            variant="outline"
            onClick={() => setRestartOpen(true)}
            disabled={!running}
            className="border-amber-500 text-amber-600 hover:bg-amber-50"
          >
            <RotateCcw className="mr-2 h-4 w-4" />
            Restart
          </Button>
        </CardContent>
      </Card>

      <StartDialog
        open={startOpen}
        onOpenChange={setStartOpen}
        onConfirm={(interval, gui) => {
          start.mutate({ interval, gui }, { onSuccess: () => setStartOpen(false) });
        }}
        isPending={start.isPending}
        title="Start Bot"
      />

      <StopDialog
        open={stopOpen}
        onOpenChange={setStopOpen}
        onConfirm={() => {
          stop.mutate(undefined, { onSuccess: () => setStopOpen(false) });
        }}
        isPending={stop.isPending}
      />

      <StartDialog
        open={restartOpen}
        onOpenChange={setRestartOpen}
        onConfirm={(interval, gui) => {
          restart.mutate({ interval, gui }, { onSuccess: () => setRestartOpen(false) });
        }}
        isPending={restart.isPending}
        title="Restart Bot"
      />
    </>
  );
}
